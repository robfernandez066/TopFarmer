extends Node2D

const FarmPlotScript = preload("res://scripts/farm/farm_plot.gd")
const PREVIEW_CROP_ID := &"sunwheat"

@onready var _farm_plot: Node = $FarmPlot
@onready var _controller: Node = $FarmPlotInteractionController

var _test_now_utc := 0


func _ready() -> void:
	_controller.connect(&"crop_planted", _on_crop_planted)
	_controller.connect(&"crop_harvested", _on_crop_harvested)
	_controller.connect(&"plot_action_ignored", _on_plot_action_ignored)
	if not _controller.configure(Callable(self, "_get_test_now_utc"), PREVIEW_CROP_ID):
		push_error("FarmPlot interaction preview failed to configure its deterministic clock")
		return
	if not _controller.register_plot(_farm_plot):
		push_error("FarmPlot interaction preview failed to register its plot")


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo or key_event.keycode != KEY_SPACE:
		return
	var ready_at_utc := int(_farm_plot.call("get_ready_at_utc"))
	if ready_at_utc >= 0:
		_test_now_utc = ready_at_utc
		get_viewport().set_input_as_handled()


func _get_test_now_utc() -> int:
	return _test_now_utc


func _on_crop_planted(plot: Node, crop_id: StringName) -> void:
	if StringName(plot.call("get_last_harvested_crop_id")) == StringName():
		print("FARM_PLOT_PREVIEW_PLANT crop=%s" % crop_id)
	else:
		print("FARM_PLOT_PREVIEW_SMART_REPLANT crop=%s" % crop_id)


func _on_crop_harvested(_plot: Node, crop_id: StringName) -> void:
	print("FARM_PLOT_PREVIEW_HARVEST crop=%s" % crop_id)


func _on_plot_action_ignored(_plot: Node, lifecycle_state: int) -> void:
	if lifecycle_state == FarmPlotScript.VisualState.GROWING:
		print("FARM_PLOT_PREVIEW_IGNORED_GROWING")
	else:
		print("FARM_PLOT_PREVIEW_IGNORED state=%d" % lifecycle_state)
