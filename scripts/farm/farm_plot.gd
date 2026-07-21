extends Node2D

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

@export var initial_visual_state: VisualState = VisualState.EMPTY

@onready var _crop_shadow: Sprite2D = $CropShadow
@onready var _crop_color: Sprite2D = $CropColor

var _visual_state: VisualState = VisualState.EMPTY
var _lifecycle_state: VisualState = VisualState.EMPTY
var _current_crop_id := StringName()
var _last_harvested_crop_id := StringName()
var _started_at_utc := -1
var _ready_at_utc := -1


func _ready() -> void:
	set_visual_state(initial_visual_state)


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
