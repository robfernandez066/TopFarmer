extends SceneTree

class FakeClock:
	extends RefCounted

	var value: Variant = 0
	var call_count := 0


	func read_now() -> Variant:
		call_count += 1
		return value


const FarmPlotScript = preload("res://scripts/farm/farm_plot.gd")
const ControllerScript = preload("res://scripts/farm/farm_plot_interaction_controller.gd")
const FARM_PLOT_SCENE := preload("res://scenes/farm/farm_plot.tscn")
const PRIMARY_CROP_ID := &"sunwheat"
const OTHER_CROP_ID := &"duskcorn"
const UNKNOWN_CROP_ID := &"unknown_crop"

var _failures: Array[String] = []
var _planted_events: Array = []
var _harvested_events: Array = []
var _ignored_events: Array = []
var _controller: Node
var _plot: Node
var _clock := FakeClock.new()
var _replacement_clock := FakeClock.new()


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	_controller = ControllerScript.new()
	root.add_child(_controller)
	_controller.connect(&"crop_planted", _on_crop_planted)
	_controller.connect(&"crop_harvested", _on_crop_harvested)
	_controller.connect(&"plot_action_ignored", _on_plot_action_ignored)
	_plot = FARM_PLOT_SCENE.instantiate()
	root.add_child(_plot)

	_verify_controller_contract()
	_verify_configuration_and_registration()
	_verify_full_primary_sequence()
	_verify_selection_override_and_empty_selection()
	_verify_unregister_and_freed_cleanup()

	_controller.set_process(false)
	_controller.free()
	_plot.free()
	call_deferred("_finish_test")


func _finish_test() -> void:
	if not _failures.is_empty():
		for failure in _failures:
			printerr("TEST FAILURE: %s" % failure)
		quit(1)
		return
	print("FARM_PLOT_INTERACTION_CONTROLLER_TEST_PASS")
	quit()


func _verify_controller_contract() -> void:
	_expect(_controller.has_signal(&"crop_planted"), "controller should declare crop_planted")
	_expect(_controller.has_signal(&"crop_harvested"), "controller should declare crop_harvested")
	_expect(_controller.has_signal(&"plot_action_ignored"), "controller should declare plot_action_ignored")
	for method_name in [&"configure", &"set_selected_crop_id", &"register_plot", &"unregister_plot"]:
		_expect(_controller.has_method(method_name), "controller should expose %s" % method_name)
	_expect(_controller.find_children("*", "AudioStreamPlayer", true, false).is_empty(), "controller should own no feedback audio")


func _verify_configuration_and_registration() -> void:
	var initial_plot := _capture_plot(_plot)
	_expect(not _controller.configure(Callable(), PRIMARY_CROP_ID), "configuration should reject an invalid callable")
	_expect(not _controller.configure(Callable(_replacement_clock, "read_now"), UNKNOWN_CROP_ID), "configuration should reject an unknown crop")
	_expect(_controller.configure(Callable(_clock, "read_now"), PRIMARY_CROP_ID), "configuration should accept a valid clock and Balance crop")
	_controller.set_process(false)
	_expect(_controller.configure(Callable(_clock, "read_now"), StringName()), "configuration should accept an empty crop selection")
	_controller.set_process(false)
	_expect(not _controller.configure(Callable(_replacement_clock, "read_now"), UNKNOWN_CROP_ID), "invalid reconfiguration should fail")
	_expect(not _controller.configure(Callable(), OTHER_CROP_ID), "invalid callable should not replace valid configuration")
	_expect(_replacement_clock.call_count == 0, "rejected replacement clock should remain unused")

	var unsupported_plot := Node.new()
	root.add_child(unsupported_plot)
	_expect(not _controller.register_plot(unsupported_plot), "registration should reject a node without FarmPlot API")
	unsupported_plot.free()
	_expect(_controller.register_plot(_plot), "registration should accept a live FarmPlot")
	_expect(not _controller.register_plot(_plot), "duplicate registration should be rejected")
	_expect(_controller_connection_count(_plot) == 1, "FarmPlot activated should connect to controller exactly once")
	_clock.value = 100
	var calls_before := _clock.call_count
	_plot.emit_signal(&"activated")
	_expect(_clock.call_count == calls_before + 1, "EMPTY activation with no selection should call UTC source once")
	_expect(_ignored_events.size() == 1 and _event_state(_ignored_events[0]) == FarmPlotScript.VisualState.EMPTY, "EMPTY activation without selection or memory should be ignored once")
	_expect(_capture_plot(_plot) == initial_plot, "ignored EMPTY activation should mutate no plot")
	_expect(_controller.set_selected_crop_id(PRIMARY_CROP_ID), "known crop selection should be valid")
	_expect(not _controller.set_selected_crop_id(UNKNOWN_CROP_ID), "unknown crop selection should be rejected")
	_expect(_capture_plot(_plot) == initial_plot, "selection changes should not mutate a plot")

	var unknown_plot := FARM_PLOT_SCENE.instantiate()
	root.add_child(unknown_plot)
	_expect(not _controller.unregister_plot(unknown_plot), "unknown plot unregister should fail")
	unknown_plot.free()


func _verify_full_primary_sequence() -> void:
	var audio := _plot.get_node(^"PlotBase/ActivationAudio") as AudioStreamPlayer
	audio.stop()
	var base_scale: Vector2 = _plot.scale
	var visual_ids := _visual_node_ids(_plot)
	_clock.value = 1000
	var calls_before := _clock.call_count
	_plot.emit_signal(&"activated")
	_expect(_clock.call_count == calls_before + 1, "EMPTY activation should call UTC source exactly once")
	_expect(_planted_events.size() == 1 and _event_crop_id(_planted_events[0]) == PRIMARY_CROP_ID, "first tap should emit one Sunwheat planted event")
	_expect(_plot.get_lifecycle_state() == FarmPlotScript.VisualState.GROWING, "first tap should plant into GROWING")
	_expect(_plot.get_current_crop_id() == PRIMARY_CROP_ID, "first tap should plant retained valid selection")
	_expect(_plot.get_started_at_utc() == 1000, "planting should use the single supplied UTC value")
	_expect(_replacement_clock.call_count == 0, "invalid configuration should preserve the original clock")
	_expect(not audio.playing, "controller should not add a second sound when activated is emitted")
	_expect(_plot.scale == base_scale, "controller should not own press-scale feedback")
	_expect(_visual_node_ids(_plot) == visual_ids, "controller action should not recreate visual or feedback nodes")

	var growing_snapshot := _capture_plot(_plot)
	_clock.value = 1001
	calls_before = _clock.call_count
	_plot.emit_signal(&"activated")
	_expect(_clock.call_count == calls_before + 1, "GROWING activation should call UTC source exactly once")
	_expect(_ignored_events.size() == 2 and _event_state(_ignored_events[1]) == FarmPlotScript.VisualState.GROWING, "GROWING tap should emit one ignored event")
	_expect(_capture_plot(_plot) == growing_snapshot, "GROWING tap should mutate no lifecycle or visual value")

	_clock.value = -1
	calls_before = _clock.call_count
	_controller._process(0.0)
	_expect(_clock.call_count == calls_before + 1, "negative process time should call UTC source only once")
	_expect(_capture_plot(_plot) == growing_snapshot, "negative process time should mutate no plot")
	_clock.value = 1.5
	calls_before = _clock.call_count
	_controller._process(0.0)
	_expect(_clock.call_count == calls_before + 1, "noninteger process time should call UTC source only once")
	_expect(_capture_plot(_plot) == growing_snapshot, "noninteger process time should mutate no plot")
	_clock.value = "invalid"
	calls_before = _clock.call_count
	_plot.emit_signal(&"activated")
	_expect(_clock.call_count == calls_before + 1, "invalid activation time should call UTC source only once")
	_expect(_ignored_events.size() == 3, "invalid activation time should emit ignored once")
	_expect(_capture_plot(_plot) == growing_snapshot, "invalid activation time should mutate no plot")

	var second_plot := FARM_PLOT_SCENE.instantiate()
	root.add_child(second_plot)
	_expect(second_plot.plant_crop(PRIMARY_CROP_ID, 1000), "second-plot test setup should plant")
	_expect(_controller.register_plot(second_plot), "controller should register a second FarmPlot")
	var ready_at_utc := int(_plot.get_ready_at_utc())
	_expect(second_plot.get_ready_at_utc() == ready_at_utc, "two-plot setup should share one deadline")
	_clock.value = ready_at_utc - 1
	calls_before = _clock.call_count
	_controller._process(0.0)
	_expect(_clock.call_count == calls_before + 1, "one process update should call UTC source once for all plots")
	_expect(_plot.get_lifecycle_state() == FarmPlotScript.VisualState.GROWING and second_plot.get_lifecycle_state() == FarmPlotScript.VisualState.GROWING, "same pre-deadline value should keep every plot GROWING")
	_clock.value = ready_at_utc
	calls_before = _clock.call_count
	_controller._process(0.0)
	_expect(_clock.call_count == calls_before + 1, "ready process update should still call UTC source only once")
	_expect(_plot.get_lifecycle_state() == FarmPlotScript.VisualState.READY and second_plot.get_lifecycle_state() == FarmPlotScript.VisualState.READY, "same exact deadline should make every plot READY")

	_expect(_controller.unregister_plot(second_plot), "registered second plot should unregister")
	_expect(not _controller.unregister_plot(second_plot), "repeated second-plot unregister should fail")
	var second_snapshot := _capture_plot(second_plot)
	calls_before = _clock.call_count
	second_plot.emit_signal(&"activated")
	_expect(_clock.call_count == calls_before, "unregistered activation should not call UTC source")
	_expect(_capture_plot(second_plot) == second_snapshot, "unregistered activation should mutate no plot")
	second_plot.free()

	_clock.value = ready_at_utc
	calls_before = _clock.call_count
	_plot.emit_signal(&"activated")
	_expect(_clock.call_count == calls_before + 1, "READY activation should call UTC source exactly once")
	_expect(_harvested_events.size() == 1 and _event_crop_id(_harvested_events[0]) == PRIMARY_CROP_ID, "READY tap should emit one Sunwheat harvested event")
	_expect(_plot.get_lifecycle_state() == FarmPlotScript.VisualState.EMPTY, "READY tap should harvest to EMPTY")
	_expect(_plot.get_current_crop_id() == StringName() and _plot.get_last_harvested_crop_id() == PRIMARY_CROP_ID, "harvest should clear current crop and remember Sunwheat")

	var harvested_snapshot := _capture_plot(_plot)
	_clock.value = ready_at_utc + 1000
	calls_before = _clock.call_count
	_controller._process(0.0)
	_expect(_clock.call_count == calls_before + 1, "EMPTY process update should call UTC source once")
	_expect(_capture_plot(_plot) == harvested_snapshot, "process updates should never auto-replant")
	_expect(_planted_events.size() == 1, "harvest should remain a distinct action from replant")

	_clock.value = ready_at_utc + 2000
	calls_before = _clock.call_count
	_plot.emit_signal(&"activated")
	_expect(_clock.call_count == calls_before + 1, "smart-replant activation should call UTC source exactly once")
	_expect(_planted_events.size() == 2 and _event_crop_id(_planted_events[1]) == PRIMARY_CROP_ID, "next EMPTY tap should smart-replant remembered Sunwheat")
	_expect(_plot.get_lifecycle_state() == FarmPlotScript.VisualState.GROWING, "smart replant should return to GROWING")


func _verify_selection_override_and_empty_selection() -> void:
	_clock.value = _plot.get_ready_at_utc()
	_controller._process(0.0)
	_expect(_plot.get_lifecycle_state() == FarmPlotScript.VisualState.READY, "selection-override setup should reach READY")
	_plot.emit_signal(&"activated")
	_expect(_harvested_events.size() == 2, "second READY tap should harvest without auto-replant")
	_expect(_plot.get_lifecycle_state() == FarmPlotScript.VisualState.EMPTY, "second harvest should leave EMPTY")
	var empty_snapshot := _capture_plot(_plot)
	_expect(_controller.set_selected_crop_id(OTHER_CROP_ID), "selection should accept another Balance crop")
	_expect(_capture_plot(_plot) == empty_snapshot, "selection override should change no plot by itself")
	_clock.value = int(_clock.value) + 500
	_plot.emit_signal(&"activated")
	_expect(_planted_events.size() == 3 and _event_crop_id(_planted_events[2]) == OTHER_CROP_ID, "different valid selection should override remembered crop")
	_expect(_plot.get_current_crop_id() == OTHER_CROP_ID and _plot.get_last_harvested_crop_id() == PRIMARY_CROP_ID, "current override crop and remembered crop should remain distinct")

	_clock.value = _plot.get_ready_at_utc()
	_controller._process(0.0)
	_plot.emit_signal(&"activated")
	_expect(_harvested_events.size() == 3 and _event_crop_id(_harvested_events[2]) == OTHER_CROP_ID, "override crop should harvest normally")
	_expect(_controller.set_selected_crop_id(StringName()), "empty selection should remain valid after harvest")
	_clock.value = int(_clock.value) + 500
	_plot.emit_signal(&"activated")
	_expect(_planted_events.size() == 4 and _event_crop_id(_planted_events[3]) == OTHER_CROP_ID, "empty selection should smart-replant remembered override crop")
	_expect(_plot.get_current_crop_id() == OTHER_CROP_ID, "empty-selection replant should use remembered crop")


func _verify_unregister_and_freed_cleanup() -> void:
	var plot_snapshot := _capture_plot(_plot)
	var planted_count := _planted_events.size()
	var harvested_count := _harvested_events.size()
	var ignored_count := _ignored_events.size()
	var calls_before := _clock.call_count
	_expect(_controller.unregister_plot(_plot), "registered primary plot should unregister")
	_expect(not _controller.unregister_plot(_plot), "repeated primary unregister should fail")
	_plot.emit_signal(&"activated")
	_expect(_clock.call_count == calls_before, "unregistered primary activation should not call UTC source")
	_expect(_capture_plot(_plot) == plot_snapshot, "unregistered primary activation should mutate no plot")
	_expect(_planted_events.size() == planted_count and _harvested_events.size() == harvested_count and _ignored_events.size() == ignored_count, "unregistered activation should emit no controller signal")
	_expect(_controller.register_plot(_plot), "primary plot should register again after clean unregister")
	_expect(_controller_connection_count(_plot) == 1, "re-registration should still connect exactly once")

	var freed_plot := FARM_PLOT_SCENE.instantiate()
	root.add_child(freed_plot)
	var freed_plot_id := freed_plot.get_instance_id()
	_expect(_controller.register_plot(freed_plot), "freed-plot cleanup setup should register")
	freed_plot.free()
	_clock.value = int(_clock.value) + 1
	calls_before = _clock.call_count
	_controller._process(0.0)
	_expect(_clock.call_count == calls_before + 1, "freed-plot cleanup process should call UTC source once")
	var registrations: Dictionary = _controller.get("_registered_plots")
	_expect(not registrations.has(freed_plot_id), "process update should remove a freed plot registration")
	_expect(_controller_connection_count(_plot) == 1, "freed sibling cleanup should preserve live plot connection")


func _controller_connection_count(plot: Node) -> int:
	var count := 0
	for connection in plot.get_signal_connection_list(&"activated"):
		var connection_callable: Callable = (connection as Dictionary)["callable"]
		if connection_callable.get_object() == _controller:
			count += 1
	return count


func _capture_plot(plot: Node) -> Array:
	var plot_base := plot.get_node(^"PlotBase") as Sprite2D
	var crop_shadow := plot.get_node(^"CropShadow") as Sprite2D
	var crop_color := plot.get_node(^"CropColor") as Sprite2D
	var audio := plot.get_node(^"PlotBase/ActivationAudio") as AudioStreamPlayer
	return [
		plot.get_lifecycle_state(), plot.get_visual_state(),
		plot.get_current_crop_id(), plot.get_last_harvested_crop_id(),
		plot.get_started_at_utc(), plot.get_ready_at_utc(),
		plot.position, plot.scale, plot.rotation,
		plot_base.get_instance_id(), crop_shadow.get_instance_id(), crop_color.get_instance_id(), audio.get_instance_id(),
		plot_base.position, crop_shadow.position, crop_color.position,
		plot_base.z_index, crop_shadow.z_index, crop_color.z_index,
		_texture_path(plot_base), _texture_path(crop_shadow), _texture_path(crop_color),
		audio.playing,
	]


func _visual_node_ids(plot: Node) -> Array:
	return [
		plot.get_node(^"PlotBase").get_instance_id(),
		plot.get_node(^"CropShadow").get_instance_id(),
		plot.get_node(^"CropColor").get_instance_id(),
		plot.get_node(^"PlotBase/HitArea").get_instance_id(),
		plot.get_node(^"PlotBase/ActivationAudio").get_instance_id(),
	]


func _event_crop_id(event: Array) -> StringName:
	return event[1]


func _event_state(event: Array) -> int:
	return event[1]


func _texture_path(sprite: Sprite2D) -> String:
	if sprite.texture == null:
		return ""
	return sprite.texture.resource_path


func _on_crop_planted(plot: Node, crop_id: StringName) -> void:
	_planted_events.append([plot, crop_id])


func _on_crop_harvested(plot: Node, crop_id: StringName) -> void:
	_harvested_events.append([plot, crop_id])


func _on_plot_action_ignored(plot: Node, lifecycle_state: int) -> void:
	_ignored_events.append([plot, lifecycle_state])


func _expect(condition: bool, description: String) -> void:
	if not condition:
		_failures.append(description)
