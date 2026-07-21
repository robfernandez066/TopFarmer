extends SceneTree

const FarmWorldScript = preload("res://scripts/farm/farm_world.gd")
const FarmPlotScript = preload("res://scripts/farm/farm_plot.gd")
const ClockScript = preload("res://scripts/platform/session_utc_clock.gd")
const FARM_WORLD_SCENE := preload("res://scenes/farm/farm_world.tscn")
const MAIN_SCENE := preload("res://scenes/main.tscn")
const MEADOW_TEXTURE_PATH := "res://assets/sprites/terrain/meadow_grass_tile_default_128.png"
const PRIMARY_CROP_ID := &"sunwheat"
const LOGICAL_RECT := Rect2(0.0, 0.0, 540.0, 960.0)


class DeterministicClock:
	extends ClockScript

	var system_utc: Variant = 1000
	var monotonic_msec: Variant = 0
	var start_call_count := 0


	func start() -> bool:
		start_call_count += 1
		return super.start()


	func set_now_utc(value: int) -> void:
		monotonic_msec = (value - int(system_utc)) * MSEC_PER_SECOND


	func _read_system_utc() -> Variant:
		return system_utc


	func _read_monotonic_msec() -> Variant:
		return monotonic_msec


class TestFarmWorld:
	extends FarmWorldScript

	var starting_plots_value: Variant = 4.0
	var supplied_clock: SessionUtcClock
	var clock_construction_count := 0
	var setup_errors: Array[String] = []


	func _read_starting_plots_value() -> Variant:
		return starting_plots_value


	func _create_session_utc_clock() -> SessionUtcClock:
		clock_construction_count += 1
		return supplied_clock


	func _report_setup_error(message: String) -> void:
		setup_errors.append(message)


var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	_verify_authored_scene()
	_verify_main_runtime()
	_verify_invalid_starting_plot_paths()
	_verify_clock_start_failure_is_atomic()
	_verify_deterministic_independent_lifecycle()
	call_deferred("_finish_test")


func _finish_test() -> void:
	if not _failures.is_empty():
		for failure in _failures:
			printerr("TEST FAILURE: %s" % failure)
		quit(1)
		return
	print("FARM_WORLD_RUNTIME_TEST_PASS")
	quit()


func _verify_authored_scene() -> void:
	var world := FARM_WORLD_SCENE.instantiate()
	_expect(world is Node2D, "FarmWorld scene root should be Node2D")
	_expect(world.get_script() == FarmWorldScript, "FarmWorld scene root should use FarmWorld")
	var authored_children := world.get_children()
	_expect(authored_children.size() == 3, "FarmWorld should have exactly three authored children")
	_expect(_child_names(authored_children) == ["MeadowBackground", "PlotLayer", "InteractionController"], "FarmWorld authored children should have exact ordered names")

	var background := world.get_node_or_null(^"MeadowBackground") as TextureRect
	var plot_layer := world.get_node_or_null(^"PlotLayer") as Node2D
	var controller := world.get_node_or_null(^"InteractionController") as FarmPlotInteractionController
	_expect(background != null, "MeadowBackground should be a TextureRect")
	_expect(plot_layer != null, "PlotLayer should be a Node2D")
	_expect(controller != null, "InteractionController should use FarmPlotInteractionController")
	if background != null:
		_expect(Rect2(background.position, background.size) == LOGICAL_RECT, "MeadowBackground should fill the 540x960 logical rect")
		_expect(background.texture != null and background.texture.resource_path == MEADOW_TEXTURE_PATH, "MeadowBackground should use only the approved meadow texture")
		_expect(background.stretch_mode == TextureRect.STRETCH_TILE, "MeadowBackground should tile instead of stretch")
		_expect(background.texture_repeat == CanvasItem.TEXTURE_REPEAT_ENABLED, "MeadowBackground should enable texture repeat")
		_expect(background.mouse_filter == Control.MOUSE_FILTER_IGNORE, "MeadowBackground should ignore pointer input")
		_expect(background.z_index < plot_layer.z_index, "MeadowBackground should draw behind PlotLayer")
	_expect(world.find_children("*", "AudioStreamPlayer", true, false).is_empty(), "authored FarmWorld and controller should add no audio player")
	world.free()


func _verify_main_runtime() -> void:
	var main := MAIN_SCENE.instantiate()
	root.add_child(main)
	_expect(main.name == "Main" and main is Node, "real Main scene should preserve its Main root")
	_expect(main.get_script() != null and main.get_script().resource_path == "res://scripts/main.gd", "Main should preserve scripts/main.gd")
	var farm_worlds: Array[Node] = []
	for child in main.get_children():
		if child.get_script() == FarmWorldScript:
			farm_worlds.append(child)
	_expect(farm_worlds.size() == 1, "Main should contain exactly one FarmWorld instance")
	var main_source := FileAccess.get_file_as_string("res://scripts/main.gd")
	_expect(main_source.contains("TOPFARMER_BOOT_OK"), "Main boot diagnostic should remain present")
	if farm_worlds.size() == 1:
		_verify_live_world_contract(farm_worlds[0])
	main.free()


func _verify_live_world_contract(world: Node) -> void:
	var balance := root.get_node_or_null(^"Balance")
	_expect(balance != null, "Balance autoload should exist")
	if balance == null:
		return
	var starting_row: Dictionary = balance.call("get_global", "STARTING_PLOTS")
	_expect(starting_row.has("Value"), "Balance should provide STARTING_PLOTS")
	if not starting_row.has("Value"):
		return
	var expected_count := int(starting_row["Value"])
	var plot_layer := world.get_node(^"PlotLayer") as Node2D
	var plots := plot_layer.get_children()
	_expect(plots.size() == expected_count, "FarmWorld plot count should equal Balance STARTING_PLOTS")
	_expect(plots.size() == FarmWorldScript.PLOT_SLOTS.size(), "current Balance should create all four Phase 2 plots")

	var instance_ids: Dictionary = {}
	var controller := world.get_node(^"InteractionController") as FarmPlotInteractionController
	for plot_index in range(plots.size()):
		var plot := plots[plot_index]
		_expect(plot.name == "Plot%02d" % (plot_index + 1), "plot should have its ordered Plot01 through Plot04 name")
		_expect(plot.get_parent() == plot_layer, "%s should be parented under PlotLayer" % plot.name)
		_expect(plot.position == FarmWorldScript.PLOT_SLOTS[plot_index], "%s should use its approved ground-contact slot" % plot.name)
		_expect(plot.scale == Vector2.ONE and plot.rotation == 0.0, "%s should have identity scale and rotation" % plot.name)
		_expect(not instance_ids.has(plot.get_instance_id()), "%s should be a distinct scene instance" % plot.name)
		instance_ids[plot.get_instance_id()] = true
		_expect(plot.get_lifecycle_state() == FarmPlotScript.VisualState.EMPTY, "%s should start EMPTY" % plot.name)
		_expect(_controller_connection_count(plot, controller) == 1, "%s should register with the controller exactly once" % plot.name)
		_expect(_sprite_inside_logical_rect(plot.get_node(^"PlotBase") as Sprite2D), "%s should remain fully inside the logical playfield" % plot.name)

	var registrations: Dictionary = controller.get("_registered_plots")
	_expect(registrations.size() == plots.size(), "controller should retain one registration per created plot")
	_expect(world.get("_session_clock") is SessionUtcClock, "FarmWorld should own one started SessionUtcClock")
	var clock := world.get("_session_clock") as SessionUtcClock
	_expect(clock != null and clock.is_started(), "FarmWorld SessionUtcClock should be started")
	_expect(StringName(controller.get("_selected_crop_id")) == PRIMARY_CROP_ID, "controller should select Sunwheat")
	_expect(world.find_children("*", "AudioStreamPlayer", true, false).size() == plots.size(), "FarmWorld should add no duplicate audio beyond one player per FarmPlot")

	var world_source := FileAccess.get_file_as_string("res://scripts/farm/farm_world.gd")
	_expect(not world_source.contains("Time."), "FarmWorld should not poll a system clock")
	_expect(not world_source.contains("KEY_SPACE") and not world_source.contains("ui_accept"), "FarmWorld should contain no fake-time shortcut")
	_expect(not world_source.contains("growth_sec"), "FarmWorld should contain no hardcoded growth duration")


func _verify_invalid_starting_plot_paths() -> void:
	var invalid_values: Array[Variant] = ["invalid", NAN, INF, 0.0, -1.0, 1.5, 5.0]
	for invalid_value in invalid_values:
		var clock := DeterministicClock.new()
		var world := _instantiate_test_world(invalid_value, clock)
		var controller := world.get_node(^"InteractionController") as FarmPlotInteractionController
		_expect(world.get_node(^"PlotLayer").get_child_count() == 0, "invalid STARTING_PLOTS should create no plots")
		_expect((controller.get("_registered_plots") as Dictionary).is_empty(), "invalid STARTING_PLOTS should register no plots")
		_expect(world.clock_construction_count == 0 and clock.start_call_count == 0, "invalid STARTING_PLOTS should fail before clock construction or start")
		_expect(world.setup_errors.size() == 1 and world.setup_errors[0].contains("STARTING_PLOTS"), "invalid STARTING_PLOTS should report one loud setup failure")
		world.free()


func _verify_clock_start_failure_is_atomic() -> void:
	var failed_clock := DeterministicClock.new()
	failed_clock.system_utc = -1
	var world := _instantiate_test_world(4.0, failed_clock)
	var controller := world.get_node(^"InteractionController") as FarmPlotInteractionController
	_expect(world.clock_construction_count == 1 and failed_clock.start_call_count == 1, "FarmWorld should construct and start its one clock exactly once")
	_expect(world.get_node(^"PlotLayer").get_child_count() == 0, "clock startup failure should create no plots")
	_expect((controller.get("_registered_plots") as Dictionary).is_empty(), "clock startup failure should leave no controller registrations")
	var configured_callable: Callable = controller.get("_now_utc_callable")
	_expect(not configured_callable.is_valid(), "clock startup failure should leave the controller callable unconfigured")
	_expect(world.setup_errors.size() == 1 and world.setup_errors[0].contains("failed to start"), "clock startup failure should report one loud setup failure")
	world.free()


func _verify_deterministic_independent_lifecycle() -> void:
	var clock := DeterministicClock.new()
	var world := _instantiate_test_world(4.0, clock)
	var controller := world.get_node(^"InteractionController") as FarmPlotInteractionController
	var plots := world.get_node(^"PlotLayer").get_children()
	_expect(world.clock_construction_count == 1 and clock.start_call_count == 1, "deterministic FarmWorld should construct and start one supplied clock")
	_expect(plots.size() == 4, "deterministic FarmWorld should create four plots")
	if plots.size() != 4:
		world.free()
		return
	var first_plot := plots[0]
	var second_plot := plots[1]
	var third_snapshot := _capture_plot(plots[2])
	var fourth_snapshot := _capture_plot(plots[3])

	clock.set_now_utc(1000)
	first_plot.emit_signal(&"activated")
	clock.set_now_utc(1007)
	second_plot.emit_signal(&"activated")
	_expect(first_plot.get_started_at_utc() == 1000 and second_plot.get_started_at_utc() == 1007, "plots planted at different clock values should keep distinct start timestamps")
	_expect(first_plot.get_ready_at_utc() != second_plot.get_ready_at_utc(), "different planting times should produce distinct absolute deadlines")
	_expect(_capture_plot(plots[2]) == third_snapshot and _capture_plot(plots[3]) == fourth_snapshot, "planting two plots should leave the other plots unchanged")

	var first_deadline := int(first_plot.get_ready_at_utc())
	var second_deadline := int(second_plot.get_ready_at_utc())
	clock.set_now_utc(first_deadline - 1)
	controller._process(0.0)
	_expect(first_plot.get_lifecycle_state() == FarmPlotScript.VisualState.GROWING, "first plot should remain GROWING before its exact deadline")
	_expect(second_plot.get_lifecycle_state() == FarmPlotScript.VisualState.GROWING, "later plot should remain GROWING before the first deadline")

	clock.set_now_utc(first_deadline)
	controller._process(0.0)
	_expect(first_plot.get_lifecycle_state() == FarmPlotScript.VisualState.READY, "first plot should become READY at its exact CSV-derived deadline")
	_expect(second_plot.get_lifecycle_state() == FarmPlotScript.VisualState.GROWING, "first deadline should not mature the later plot")
	var ready_snapshot := _capture_plot(first_plot)
	clock.set_now_utc(first_deadline + 1)
	controller._process(0.0)
	_expect(_capture_plot(first_plot) == ready_snapshot, "READY should wait without auto-harvest or auto-replant")

	clock.set_now_utc(second_deadline)
	controller._process(0.0)
	_expect(first_plot.get_lifecycle_state() == FarmPlotScript.VisualState.READY and second_plot.get_lifecycle_state() == FarmPlotScript.VisualState.READY, "each plot should mature only when the shared clock reaches its own deadline")
	var second_ready_snapshot := _capture_plot(second_plot)
	first_plot.emit_signal(&"activated")
	_expect(first_plot.get_lifecycle_state() == FarmPlotScript.VisualState.EMPTY, "one READY tap should harvest only the tapped plot to EMPTY")
	_expect(_capture_plot(second_plot) == second_ready_snapshot, "harvesting one plot should not alter another READY plot")

	var harvested_snapshot := _capture_plot(first_plot)
	clock.set_now_utc(second_deadline + 10)
	controller._process(0.0)
	_expect(_capture_plot(first_plot) == harvested_snapshot, "process updates should never auto-replant a harvested plot")
	clock.set_now_utc(second_deadline + 20)
	first_plot.emit_signal(&"activated")
	_expect(first_plot.get_lifecycle_state() == FarmPlotScript.VisualState.GROWING, "one later EMPTY tap should smart-replant the remembered Sunwheat")
	_expect(first_plot.get_started_at_utc() == second_deadline + 20, "smart replant should use the current shared clock value")
	_expect(_capture_plot(second_plot) == second_ready_snapshot, "smart replant should alter only the tapped harvested plot")
	world.free()


func _instantiate_test_world(starting_plots_value: Variant, clock: SessionUtcClock) -> TestFarmWorld:
	var world := FARM_WORLD_SCENE.instantiate()
	world.set_script(TestFarmWorld)
	world.starting_plots_value = starting_plots_value
	world.supplied_clock = clock
	root.add_child(world)
	return world as TestFarmWorld


func _controller_connection_count(plot: Node, controller: Node) -> int:
	var count := 0
	for connection in plot.get_signal_connection_list(&"activated"):
		var callback: Callable = (connection as Dictionary)["callable"]
		if callback.get_object() == controller:
			count += 1
	return count


func _sprite_inside_logical_rect(sprite: Sprite2D) -> bool:
	var local_rect := sprite.get_rect()
	for corner in [local_rect.position, Vector2(local_rect.end.x, local_rect.position.y), local_rect.end, Vector2(local_rect.position.x, local_rect.end.y)]:
		if not LOGICAL_RECT.has_point(sprite.to_global(corner)):
			return false
	return true


func _capture_plot(plot: Node) -> Array:
	return [
		plot.get_lifecycle_state(),
		plot.get_visual_state(),
		plot.get_current_crop_id(),
		plot.get_last_harvested_crop_id(),
		plot.get_started_at_utc(),
		plot.get_ready_at_utc(),
		plot.position,
		plot.scale,
		plot.rotation,
	]


func _child_names(nodes: Array[Node]) -> Array[String]:
	var names: Array[String] = []
	for node in nodes:
		names.append(String(node.name))
	return names


func _expect(condition: bool, description: String) -> void:
	if not condition:
		_failures.append(description)
