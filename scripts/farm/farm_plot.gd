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
var _mouse_gesture_active := false
var _gesture_cancelled := false
var _feedback_active := false
var _pre_press_scale := Vector2.ONE


func _ready() -> void:
	_hit_area.input_event.connect(_on_hit_area_input_event)
	visibility_changed.connect(_on_visibility_changed)
	set_visual_state(initial_visual_state)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_track_touch_event(event as InputEventScreenTouch)
	elif event is InputEventScreenDrag:
		_track_touch_drag(event as InputEventScreenDrag)
	elif event is InputEventMouseButton:
		_track_mouse_button(event as InputEventMouseButton)
	elif event is InputEventMouseMotion:
		_track_mouse_motion(event as InputEventMouseMotion)


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
		if _mouse_gesture_active:
			_discard_gesture()
		_active_touch_index = touch_event.index
		_gesture_cancelled = false
		_begin_feedback()
		_mark_input_handled(viewport)
	elif event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.device == InputEvent.DEVICE_ID_EMULATION:
			return
		if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
			return
		if _active_touch_index != NO_ACTIVE_TOUCH or _mouse_gesture_active:
			return
		_mouse_gesture_active = true
		_gesture_cancelled = false
		_begin_feedback()
		_mark_input_handled(viewport)


func _track_touch_event(event: InputEventScreenTouch) -> void:
	if event.index != _active_touch_index:
		return
	get_viewport().set_input_as_handled()
	if event.pressed:
		return
	var should_activate := not event.canceled and not _gesture_cancelled and _is_point_inside_hit_area(event.position)
	if not should_activate:
		_cancel_feedback()
	_finish_gesture(should_activate)


func _track_touch_drag(event: InputEventScreenDrag) -> void:
	if event.index != _active_touch_index:
		return
	get_viewport().set_input_as_handled()
	if not _is_point_inside_hit_area(event.position):
		_cancel_feedback()


func _track_mouse_button(event: InputEventMouseButton) -> void:
	if event.device == InputEvent.DEVICE_ID_EMULATION:
		return
	if event.button_index != MOUSE_BUTTON_LEFT or event.pressed:
		return
	if not _mouse_gesture_active or _active_touch_index != NO_ACTIVE_TOUCH:
		return
	get_viewport().set_input_as_handled()
	var should_activate := not _gesture_cancelled and _is_point_inside_hit_area(event.position)
	if not should_activate:
		_cancel_feedback()
	_finish_gesture(should_activate)


func _track_mouse_motion(event: InputEventMouseMotion) -> void:
	if not _mouse_gesture_active or _active_touch_index != NO_ACTIVE_TOUCH:
		return
	if not _is_point_inside_hit_area(event.position):
		_cancel_feedback()


func _begin_feedback() -> void:
	_pre_press_scale = scale
	_feedback_active = true
	scale = _pre_press_scale * PRESS_SCALE_FACTOR
	_activation_audio.play()


func _cancel_feedback() -> void:
	_gesture_cancelled = true
	_restore_feedback()


func _restore_feedback() -> void:
	if not _feedback_active:
		return
	scale = _pre_press_scale
	_feedback_active = false


func _finish_gesture(should_activate: bool) -> void:
	_restore_feedback()
	_active_touch_index = NO_ACTIVE_TOUCH
	_mouse_gesture_active = false
	var emit_activation := should_activate and not _gesture_cancelled
	_gesture_cancelled = false
	if emit_activation:
		activated.emit()


func _discard_gesture() -> void:
	_restore_feedback()
	_active_touch_index = NO_ACTIVE_TOUCH
	_mouse_gesture_active = false
	_gesture_cancelled = false


func _is_point_inside_hit_area(viewport_position: Vector2) -> bool:
	var rectangle := _hit_shape.shape as RectangleShape2D
	if rectangle == null:
		return false
	var local_point := _hit_area.to_local(viewport_position)
	if _feedback_active:
		local_point *= PRESS_SCALE_FACTOR
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
