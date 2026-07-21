extends Node2D

enum VisualState {
	EMPTY,
	GROWING,
	READY,
}

const GROWING_SHADOW_TEXTURE := preload("res://assets/sprites/crops/sunwheat_shadow_growing_256.png")
const GROWING_COLOR_TEXTURE := preload("res://assets/sprites/crops/sunwheat_crop_growing_256.png")
const READY_SHADOW_TEXTURE := preload("res://assets/sprites/crops/sunwheat_shadow_ready_256.png")
const READY_COLOR_TEXTURE := preload("res://assets/sprites/crops/sunwheat_crop_ready_256.png")

@export var initial_visual_state: VisualState = VisualState.EMPTY

@onready var _crop_shadow: Sprite2D = $CropShadow
@onready var _crop_color: Sprite2D = $CropColor

var _visual_state: VisualState = VisualState.EMPTY


func _ready() -> void:
	set_visual_state(initial_visual_state)


func set_visual_state(state: VisualState) -> void:
	match state:
		VisualState.EMPTY:
			_crop_shadow.texture = null
			_crop_color.texture = null
			_crop_shadow.visible = false
			_crop_color.visible = false
		VisualState.GROWING:
			_crop_shadow.texture = GROWING_SHADOW_TEXTURE
			_crop_color.texture = GROWING_COLOR_TEXTURE
			_crop_shadow.visible = true
			_crop_color.visible = true
		VisualState.READY:
			_crop_shadow.texture = READY_SHADOW_TEXTURE
			_crop_color.texture = READY_COLOR_TEXTURE
			_crop_shadow.visible = true
			_crop_color.visible = true
	_visual_state = state


func get_visual_state() -> VisualState:
	return _visual_state
