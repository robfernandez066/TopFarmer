extends Node2D

signal activated

enum VisualState {
	EMPTY,
	GROWING,
	READY,
}

const GROWING_SHADOW_TEXTURE := preload("res://assets/sprites/crops/sunwheat_shadow_growing_256.png")
const GROWING_COLOR_TEXTURE := preload("res://assets/sprites/crops/sunwheat_crop_growing_256.png")
const READY_SHADOW_TEXTURE := preload("res://assets/sprites/crops/sunwheat_shadow_ready_placeholder_256.png")
const READY_COLOR_TEXTURE := preload("res://assets/sprites/crops/sunwheat_crop_ready_placeholder_256.png")
const EMPTY_CROP_POSITION := Vector2(-128.0, -232.5)
const GROWING_CROP_POSITION := Vector2(-127.0, -232.5)
const READY_CROP_POSITION := Vector2(-128.0, -232.5)
const MAX_TIMESTAMP := 9223372036854775807
const INT64_LIMIT_AS_FLOAT := 9223372036854775808.0
const PRESS_SCALE_FACTOR := 0.97
const PULSE_HALF_DURATION := 0.05
const CONFIRMED_TAP_META := &"farm_plot_confirmed_tap"
const NO_ACTIVE_TOUCH := -1

@export var initial_visual_state: VisualState = VisualState.EMPTY

@onready var _crop_shadow: Sprite2D = $CropShadow
@onready var _crop_color: Sprite2D = $CropColor
@onready var _hit_area: Area2D = $PlotBase/HitArea
@onready var _hit_shape: CollisionShape2D = $PlotBase/HitArea/CollisionShape2D
@onready var _activation_audio: AudioStreamPlayer = $PlotBase/ActivationAudio

var _visual_state: VisualState = VisualState.EMPTY
var _lifecycle_state: VisualState = VisualState.EMPTY
var _current_crop_id := StringName()
var _last_harvested_crop_id := StringName()
var _started_at_utc := -1
var _ready_at_utc := -1
var _active_touch_index := NO_ACTIVE_TOUCH
var _mouse_candidate_active := false
var _candidate_base_scale := Vector2.ONE
var _pulse_tween: Tween
var _pulse_active := false
var _pulse_base_scale := Vector2.ONE


func _ready() -> void:
	_hit_area.input_event.connect(_on_hit_area_input_event)
	visibility_changed.connect(_on_visibility_changed)
	set_visual_state(initial_visual_state)


func _input(event: InputEvent) -> void:
	if not event.has_meta(CONFIRMED_TAP_META):
		return
	if event is InputEventScreenTouch:
		_confirm_touch_tap(event as InputEventScreenTouch)
	elif event is InputEventMouseButton:
		_confirm_mouse_tap(event as InputEventMouseButton)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		_discard_gesture()


func _exit_tree() -> void:
	_discard_gesture()


func set_visual_state(state: VisualState) -> void:
	match state:
		VisualState.EMPTY:
			_apply_crop_visual(null, null, EMPTY_CROP_POSITION, false)
		VisualState.GROWING:
			_apply_crop_visual(GROWING_SHADOW_TEXTURE, GROWING_COLOR_TEXTURE, GROWING_CROP_POSITION, true)
		VisualState.READY:
			_apply_crop_visual(READY_SHADOW_TEXTURE, READY_COLOR_TEXTURE, READY_CROP_POSITION, true)
	_visual_state = state


func get_visual_state() -> VisualState:
	return _visual_state


func plant_crop(crop_id: StringName, started_at_utc: int) -> bool:
	if _lifecycle_state != VisualState.EMPTY or crop_id == StringName() or started_at_utc < 0:
		return false

	var balance := get_node_or_null(^"/root/Balance")
	if balance == null:
		push_error("FarmPlot cannot access the Balance autoload")
		return false
	var crop_row: Dictionary = balance.call("get_crop", String(crop_id))
	if crop_row.is_empty():
		return false
	var growth_seconds := _validated_growth_seconds(crop_id, crop_row, started_at_utc)
	if growth_seconds < 0:
		return false

	_current_crop_id = crop_id
	_started_at_utc = started_at_utc
	_ready_at_utc = started_at_utc + growth_seconds
	_set_lifecycle_state(VisualState.GROWING)
	return true


func update_growth(now_utc: int) -> void:
	if _lifecycle_state != VisualState.GROWING or now_utc < _started_at_utc:
		return
	if now_utc >= _ready_at_utc:
		_set_lifecycle_state(VisualState.READY)


func harvest_crop() -> StringName:
	if _lifecycle_state != VisualState.READY:
		return StringName()

	var harvested_crop_id := _current_crop_id
	_last_harvested_crop_id = harvested_crop_id
	_current_crop_id = StringName()
	_started_at_utc = -1
	_ready_at_utc = -1
	_set_lifecycle_state(VisualState.EMPTY)
	return harvested_crop_id


func replant_last_crop(started_at_utc: int) -> bool:
	if _lifecycle_state != VisualState.EMPTY or _last_harvested_crop_id == StringName():
		return false
	return plant_crop(_last_harvested_crop_id, started_at_utc)


func get_current_crop_id() -> StringName:
	return _current_crop_id


func get_last_harvested_crop_id() -> StringName:
	return _last_harvested_crop_id


func get_started_at_utc() -> int:
	return _started_at_utc


func get_ready_at_utc() -> int:
	return _ready_at_utc


func get_lifecycle_state() -> int:
	return _lifecycle_state


func _on_hit_area_input_event(viewport: Node, event: InputEvent, _shape_index: int) -> void:
	if event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if not touch_event.pressed or _active_touch_index != NO_ACTIVE_TOUCH:
			return
		_mouse_candidate_active = false
		_active_touch_index = touch_event.index
		_candidate_base_scale = _stable_base_scale()
		_mark_input_handled(viewport)
	elif event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.device == InputEvent.DEVICE_ID_EMULATION:
			return
		if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
			return
		if _active_touch_index != NO_ACTIVE_TOUCH or _mouse_candidate_active:
			return
		_mouse_candidate_active = true
		_candidate_base_scale = _stable_base_scale()
		_mark_input_handled(viewport)


func _confirm_touch_tap(event: InputEventScreenTouch) -> void:
	if event.index != _active_touch_index:
		return
	var base_scale := _candidate_base_scale
	_active_touch_index = NO_ACTIVE_TOUCH
	if event.pressed or event.canceled or not _is_point_inside_hit_area(event.position):
		return
	_run_confirmed_feedback(base_scale)


func _confirm_mouse_tap(event: InputEventMouseButton) -> void:
	if event.device == InputEvent.DEVICE_ID_EMULATION:
		return
	if event.button_index != MOUSE_BUTTON_LEFT or event.pressed:
		return
	if not _mouse_candidate_active or _active_touch_index != NO_ACTIVE_TOUCH:
		return
	var base_scale := _candidate_base_scale
	_mouse_candidate_active = false
	if not _is_point_inside_hit_area(event.position):
		return
	_run_confirmed_feedback(base_scale)


func _run_confirmed_feedback(base_scale: Vector2) -> void:
	_cancel_pulse()
	_pulse_base_scale = base_scale
	_pulse_active = true
	scale = _pulse_base_scale
	_activation_audio.play()
	activated.emit()
	var tween := create_tween()
	_pulse_tween = tween
	tween.tween_property(self, ^"scale", _pulse_base_scale * PRESS_SCALE_FACTOR, PULSE_HALF_DURATION).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, ^"scale", _pulse_base_scale, PULSE_HALF_DURATION).set_trans(Tween.TRANS_LINEAR)
	tween.finished.connect(_on_pulse_finished.bind(tween))


func _on_pulse_finished(completed_tween: Tween) -> void:
	if _pulse_tween != completed_tween:
		return
	scale = _pulse_base_scale
	_pulse_tween = null
	_pulse_active = false


func _cancel_pulse() -> void:
	if _pulse_tween != null:
		_pulse_tween.kill()
		_pulse_tween = null
	if _pulse_active:
		scale = _pulse_base_scale
	_pulse_active = false


func _stable_base_scale() -> Vector2:
	if _pulse_active:
		return _pulse_base_scale
	return scale


func _discard_gesture() -> void:
	_active_touch_index = NO_ACTIVE_TOUCH
	_mouse_candidate_active = false
	_cancel_pulse()


func _is_point_inside_hit_area(viewport_position: Vector2) -> bool:
	var rectangle := _hit_shape.shape as RectangleShape2D
	if rectangle == null:
		return false
	var local_point := _hit_area.to_local(viewport_position)
	var shape_point := local_point - _hit_shape.position
	return Rect2(-rectangle.size * 0.5, rectangle.size).has_point(shape_point)


func _mark_input_handled(viewport: Node) -> void:
	var input_viewport := viewport as Viewport
	if input_viewport != null:
		input_viewport.set_input_as_handled()


func _on_visibility_changed() -> void:
	if not is_visible_in_tree():
		_discard_gesture()


func _validated_growth_seconds(crop_id: StringName, crop_row: Dictionary, started_at_utc: int) -> int:
	if not crop_row.has("growth_sec_eff"):
		return _reject_growth_duration(crop_id, "missing value")

	var raw_growth: Variant = crop_row["growth_sec_eff"]
	var growth_seconds: int
	match typeof(raw_growth):
		TYPE_INT:
			growth_seconds = int(raw_growth)
		TYPE_FLOAT:
			var growth_float := float(raw_growth)
			if not is_finite(growth_float):
				return _reject_growth_duration(crop_id, "nonfinite value")
			var rounded_growth: float = ceil(growth_float)
			if rounded_growth >= INT64_LIMIT_AS_FLOAT:
				return _reject_growth_duration(crop_id, "value exceeds integer timestamp range")
			growth_seconds = int(rounded_growth)
		_:
			return _reject_growth_duration(crop_id, "nonnumeric value")

	if growth_seconds <= 0:
		return _reject_growth_duration(crop_id, "value must be positive")
	if growth_seconds > MAX_TIMESTAMP - started_at_utc:
		return _reject_growth_duration(crop_id, "ready timestamp exceeds integer range")
	return growth_seconds


func _reject_growth_duration(crop_id: StringName, reason: String) -> int:
	push_error("FarmPlot crop '%s' has invalid growth_sec_eff: %s" % [crop_id, reason])
	return -1


func _set_lifecycle_state(state: VisualState) -> void:
	_lifecycle_state = state
	set_visual_state(state)


func _apply_crop_visual(shadow_texture: Texture2D, color_texture: Texture2D, pair_position: Vector2, is_visible: bool) -> void:
	_crop_shadow.texture = shadow_texture
	_crop_color.texture = color_texture
	_crop_shadow.position = pair_position
	_crop_color.position = pair_position
	_crop_shadow.visible = is_visible
	_crop_color.visible = is_visible
