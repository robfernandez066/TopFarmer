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

@export var initial_visual_state: VisualState = VisualState.EMPTY

@onready var _crop_shadow: Sprite2D = $CropShadow
@onready var _crop_color: Sprite2D = $CropColor

var _visual_state: VisualState = VisualState.EMPTY


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


func _apply_crop_visual(shadow_texture: Texture2D, color_texture: Texture2D, pair_position: Vector2, is_visible: bool) -> void:
	_crop_shadow.texture = shadow_texture
	_crop_color.texture = color_texture
	_crop_shadow.position = pair_position
	_crop_color.position = pair_position
	_crop_shadow.visible = is_visible
	_crop_color.visible = is_visible
