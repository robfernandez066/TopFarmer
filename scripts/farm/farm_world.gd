class_name FarmWorld
extends Node2D

const FARM_PLOT_SCENE := preload("res://scenes/farm/farm_plot.tscn")
const PLOT_SLOTS: Array[Vector2] = [
	Vector2(140.0, 390.0),
	Vector2(400.0, 390.0),
	Vector2(140.0, 710.0),
	Vector2(400.0, 710.0),
]
const SELECTED_CROP_ID := &"sunwheat"
const STARTING_PLOTS_KEY := "STARTING_PLOTS"

@onready var _plot_layer: Node2D = $PlotLayer
@onready var _interaction_controller: FarmPlotInteractionController = $InteractionController

var _session_clock: SessionUtcClock


func _ready() -> void:
	var plot_count := _validate_starting_plot_count(_read_starting_plots_value())
	if plot_count < 0:
		_report_setup_error("FarmWorld requires STARTING_PLOTS to be a finite positive whole number no greater than available plot slots")
		return

	_session_clock = _create_session_utc_clock()
	if _session_clock == null:
		_report_setup_error("FarmWorld could not create its SessionUtcClock")
		return
	if not _session_clock.start():
		_report_setup_error("FarmWorld SessionUtcClock failed to start")
		return
	if not _interaction_controller.configure(Callable(_session_clock, "now_utc"), SELECTED_CROP_ID):
		_report_setup_error("FarmWorld could not configure its interaction controller")
		return

	for plot_index in range(plot_count):
		var plot := FARM_PLOT_SCENE.instantiate()
		plot.name = "Plot%02d" % (plot_index + 1)
		plot.position = PLOT_SLOTS[plot_index]
		plot.scale = Vector2.ONE
		plot.rotation = 0.0
		_plot_layer.add_child(plot)
		if not _interaction_controller.register_plot(plot):
			_report_setup_error("FarmWorld could not register %s" % plot.name)
			_rollback_plots()
			return


func _create_session_utc_clock() -> SessionUtcClock:
	return SessionUtcClock.new()


func _read_starting_plots_value() -> Variant:
	var balance := get_node_or_null(^"/root/Balance")
	if balance == null:
		return null
	var row: Dictionary = balance.call("get_global", STARTING_PLOTS_KEY)
	if not row.has("Value"):
		return null
	return row["Value"]


func _validate_starting_plot_count(raw_value: Variant) -> int:
	var numeric_value: float
	match typeof(raw_value):
		TYPE_INT:
			numeric_value = float(raw_value)
		TYPE_FLOAT:
			numeric_value = float(raw_value)
		_:
			return -1
	if not is_finite(numeric_value):
		return -1
	if numeric_value != floor(numeric_value):
		return -1
	if numeric_value <= 0.0 or numeric_value > float(PLOT_SLOTS.size()):
		return -1
	return int(numeric_value)


func _report_setup_error(message: String) -> void:
	push_error(message)


func _rollback_plots() -> void:
	for plot in _plot_layer.get_children():
		_interaction_controller.unregister_plot(plot)
		plot.queue_free()
