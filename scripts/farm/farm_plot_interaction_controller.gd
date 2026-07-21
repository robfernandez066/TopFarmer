class_name FarmPlotInteractionController
extends Node

signal crop_planted(plot, crop_id)
signal crop_harvested(plot, crop_id)
signal plot_action_ignored(plot, lifecycle_state)

const FarmPlotScript = preload("res://scripts/farm/farm_plot.gd")
const REQUIRED_PLOT_METHODS := [
	&"plant_crop",
	&"update_growth",
	&"harvest_crop",
	&"replant_last_crop",
	&"get_current_crop_id",
	&"get_last_harvested_crop_id",
	&"get_started_at_utc",
	&"get_ready_at_utc",
	&"get_lifecycle_state",
]

var _now_utc_callable := Callable()
var _selected_crop_id := StringName()
var _registered_plots: Dictionary = {}


func _init() -> void:
	set_process(false)


func configure(now_utc_callable: Callable, selected_crop_id: StringName) -> bool:
	if not now_utc_callable.is_valid() or not _is_valid_selection(selected_crop_id):
		return false
	_now_utc_callable = now_utc_callable
	_selected_crop_id = selected_crop_id
	set_process(true)
	return true


func set_selected_crop_id(crop_id: StringName) -> bool:
	if not _is_valid_selection(crop_id):
		return false
	_selected_crop_id = crop_id
	return true


func register_plot(plot: Node) -> bool:
	_cleanup_freed_plots()
	if not _is_supported_plot(plot):
		return false
	var plot_id := plot.get_instance_id()
	if _registered_plots.has(plot_id):
		return false
	var activation_callback := Callable(self, "_on_plot_activated").bind(plot_id)
	var connection_error := plot.connect(&"activated", activation_callback)
	if connection_error != OK:
		return false
	_registered_plots[plot_id] = {
		"plot_reference": weakref(plot),
		"activation_callback": activation_callback,
	}
	return true


func unregister_plot(plot: Node) -> bool:
	if not is_instance_valid(plot):
		return false
	var plot_id := plot.get_instance_id()
	if not _registered_plots.has(plot_id):
		return false
	_remove_registration(plot_id, plot)
	return true


func _process(_delta: float) -> void:
	var time_result := _read_now_utc()
	if not time_result["ok"]:
		return
	var now_utc: int = time_result["value"]
	for plot in _get_live_registered_plots():
		plot.call("update_growth", now_utc)


func _exit_tree() -> void:
	for plot_id in _registered_plots.keys():
		var plot := _get_registered_plot(plot_id)
		_remove_registration(plot_id, plot)
	set_process(false)


func _on_plot_activated(plot_id: int) -> void:
	var plot := _get_registered_plot(plot_id)
	if plot == null:
		_registered_plots.erase(plot_id)
		return

	var lifecycle_state := int(plot.call("get_lifecycle_state"))
	var time_result := _read_now_utc()
	if not time_result["ok"]:
		plot_action_ignored.emit(plot, lifecycle_state)
		return
	var now_utc: int = time_result["value"]

	match lifecycle_state:
		FarmPlotScript.VisualState.READY:
			var harvested_crop_id := StringName(plot.call("harvest_crop"))
			if harvested_crop_id == StringName():
				plot_action_ignored.emit(plot, lifecycle_state)
			else:
				crop_harvested.emit(plot, harvested_crop_id)
		FarmPlotScript.VisualState.GROWING:
			plot_action_ignored.emit(plot, lifecycle_state)
		FarmPlotScript.VisualState.EMPTY:
			_apply_empty_action(plot, now_utc, lifecycle_state)
		_:
			plot_action_ignored.emit(plot, lifecycle_state)


func _apply_empty_action(plot: Node, now_utc: int, lifecycle_state: int) -> void:
	var last_crop_id := StringName(plot.call("get_last_harvested_crop_id"))
	var action_succeeded := false
	if last_crop_id != StringName() and (_selected_crop_id == StringName() or _selected_crop_id == last_crop_id):
		action_succeeded = bool(plot.call("replant_last_crop", now_utc))
	elif _selected_crop_id != StringName():
		action_succeeded = bool(plot.call("plant_crop", _selected_crop_id, now_utc))

	if not action_succeeded:
		plot_action_ignored.emit(plot, lifecycle_state)
		return
	var planted_crop_id := StringName(plot.call("get_current_crop_id"))
	if planted_crop_id == StringName():
		plot_action_ignored.emit(plot, lifecycle_state)
		return
	crop_planted.emit(plot, planted_crop_id)


func _read_now_utc() -> Dictionary:
	if not _now_utc_callable.is_valid():
		_print_time_diagnostic("no valid UTC callable")
		return {"ok": false, "value": -1}
	var supplied_time: Variant = _now_utc_callable.call()
	if typeof(supplied_time) != TYPE_INT:
		_print_time_diagnostic("UTC callable must return a nonnegative integer")
		return {"ok": false, "value": -1}
	var now_utc := int(supplied_time)
	if now_utc < 0:
		_print_time_diagnostic("UTC callable returned a negative integer")
		return {"ok": false, "value": -1}
	return {"ok": true, "value": now_utc}


func _print_time_diagnostic(message: String) -> void:
	print("FARM_PLOT_INTERACTION_CONTROLLER_DIAGNOSTIC: %s" % message)


func _is_valid_selection(crop_id: StringName) -> bool:
	if crop_id == StringName():
		return true
	var balance := get_node_or_null(^"/root/Balance")
	if balance == null:
		return false
	var crop_row: Dictionary = balance.call("get_crop", String(crop_id))
	return not crop_row.is_empty()


func _is_supported_plot(plot: Node) -> bool:
	if not is_instance_valid(plot) or plot.is_queued_for_deletion() or not plot.has_signal(&"activated"):
		return false
	for method_name in REQUIRED_PLOT_METHODS:
		if not plot.has_method(method_name):
			return false
	return true


func _get_live_registered_plots() -> Array[Node]:
	var plots: Array[Node] = []
	for plot_id in _registered_plots.keys():
		var plot := _get_registered_plot(plot_id)
		if plot == null or plot.is_queued_for_deletion():
			_remove_registration(plot_id, plot)
		else:
			plots.append(plot)
	return plots


func _cleanup_freed_plots() -> void:
	_get_live_registered_plots()


func _get_registered_plot(plot_id: int) -> Node:
	if not _registered_plots.has(plot_id):
		return null
	var entry: Dictionary = _registered_plots[plot_id]
	var plot_reference := entry["plot_reference"] as WeakRef
	if plot_reference == null:
		return null
	var plot := plot_reference.get_ref() as Node
	if not is_instance_valid(plot):
		return null
	return plot


func _remove_registration(plot_id: int, plot: Node) -> void:
	if not _registered_plots.has(plot_id):
		return
	var entry: Dictionary = _registered_plots[plot_id]
	var activation_callback: Callable = entry["activation_callback"]
	if is_instance_valid(plot) and plot.is_connected(&"activated", activation_callback):
		plot.disconnect(&"activated", activation_callback)
	_registered_plots.erase(plot_id)
