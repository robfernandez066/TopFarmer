extends SceneTree

const CameraScript = preload("res://scripts/farm/farm_camera_controller.gd")
const FarmWorldScript = preload("res://scripts/farm/farm_world.gd")
const ClockScript = preload("res://scripts/platform/session_utc_clock.gd")
const FARM_WORLD_SCENE := preload("res://scenes/farm/farm_world.tscn")
const VIEWPORT_SIZE := Vector2(540.0, 960.0)
const CENTER := VIEWPORT_SIZE * 0.5
const HIT_SHAPE_POSITION := Vector2(0.0, -112.0)
const PAN_THRESHOLD := 12.0
const PRESS_SCALE_FACTOR := 0.97


class DeterministicClock:
	extends ClockScript

	var system_utc: Variant = 1000
	var monotonic_msec: Variant = 0


	func _read_system_utc() -> Variant:
		return system_utc


	func _read_monotonic_msec() -> Variant:
		return monotonic_msec


class DeterministicCamera:
	extends CameraScript


	func _get_camera_viewport_size() -> Vector2:
		return VIEWPORT_SIZE


class TestFarmWorld:
	extends FarmWorldScript

	var supplied_clock: SessionUtcClock
	var supplied_camera: FarmCameraController


	func _create_session_utc_clock() -> SessionUtcClock:
		return supplied_clock


	func _create_farm_camera_controller() -> FarmCameraController:
		return supplied_camera


var _failures: Array[String] = []
var _world: TestFarmWorld
var _camera: DeterministicCamera
var _plots: Array[Node] = []
var _activation_counts: Dictionary = {}


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var clock := DeterministicClock.new()
	_camera = DeterministicCamera.new()
	var world_instance := FARM_WORLD_SCENE.instantiate()
	world_instance.set_script(TestFarmWorld)
	_world = world_instance as TestFarmWorld
	_world.supplied_clock = clock
	_world.supplied_camera = _camera
	root.add_child(_world)
	_plots.assign(_world.get_node(^"PlotLayer").get_children())
	for plot in _plots:
		_activation_counts[plot.get_instance_id()] = 0
		plot.activated.connect(_on_plot_activated.bind(plot))

	await _verify_silent_hold_and_confirmed_tap()
	await _verify_pinch_variants_on_every_plot()
	await _verify_multitouch_and_pan_silence()
	_verify_threshold_and_release_rules()
	_verify_focus_visibility_and_scene_recovery()
	_verify_pulse_interruption()
	_verify_mouse_parity()

	_stop_all_audio()
	await create_timer(0.25).timeout
	_world.queue_free()
	await process_frame
	await process_frame
	if not _failures.is_empty():
		for failure in _failures:
			printerr("TEST FAILURE: %s" % failure)
		quit(1)
		return
	print("FARM_GESTURE_FEEDBACK_TEST_PASS")
	quit()


func _verify_silent_hold_and_confirmed_tap() -> void:
	_reset_world_input()
	var plot := _plots[0]
	var point := _plot_hit_screen_position(plot)
	var before := _activation_count(plot)
	var base_scale: Vector2 = plot.scale
	var base_position: Vector2 = plot.position
	var audio := _audio(plot)
	_press_plot_touch(plot, _touch_event(1, point, true))
	_expect(plot.scale == base_scale and not audio.playing, "plot touch-down should be exactly unscaled and silent")
	_expect(_activation_count(plot) == before, "plot touch-down should not activate")
	await create_timer(0.08).timeout
	_expect(plot.scale == base_scale and not audio.playing and _activation_count(plot) == before, "held possible tap should remain inert")

	_camera._input(_touch_event(1, point, false))
	_expect(_activation_count(plot) == before + 1 and audio.playing, "confirmed release should click and activate exactly once")
	_expect(plot.scale == base_scale and plot.position == base_position, "confirmed pulse should begin from the exact anchored transform")
	_advance_pulse(plot, 0.05)
	_expect(plot.scale.is_equal_approx(base_scale * PRESS_SCALE_FACTOR), "confirmed pulse should reach 0.97 after 0.05 seconds")
	_expect(plot.position == base_position, "confirmed down pulse should retain the ground-contact origin")
	_advance_pulse(plot, 0.05)
	_expect(plot.scale == base_scale and plot.position == base_position, "confirmed pulse should restore exactly after 0.10 seconds")


func _verify_pinch_variants_on_every_plot() -> void:
	await _perform_pinch(_plots[0], 10, Vector2(55.0, 45.0), Vector2(145.0, 120.0), false, "fast pinch-out from Plot01")
	await _perform_pinch(_plots[1], 20, Vector2(-55.0, 45.0), Vector2(-145.0, 120.0), true, "slow pinch-out from Plot02")
	await _perform_pinch(_plots[2], 30, Vector2(145.0, -120.0), Vector2(55.0, -45.0), false, "fast pinch-in from Plot03", true)
	await _perform_pinch(_plots[3], 40, Vector2(-145.0, -120.0), Vector2(-55.0, -45.0), true, "slow pinch-in from Plot04", true)


func _perform_pinch(plot: Node, first_id: int, second_offset: Vector2, final_offset: Vector2, slow: bool, description: String, start_zoomed := false) -> void:
	_reset_world_input()
	if start_zoomed:
		_camera.zoom = Vector2.ONE * 2.0
		_camera.position = CENTER
		_camera._clamp_camera_position()
	var first := _plot_hit_screen_position(plot)
	var second := first + second_offset
	var final_second := first + final_offset
	var before := _capture_all_plots()
	var activations_before := _total_activations()
	_press_plot_touch(plot, _touch_event(first_id, first, true))
	_expect(_all_feedback_idle(), "%s first touch should remain silent and unscaled" % description)
	_camera._input(_touch_event(first_id + 1, second, true))
	if slow:
		for fraction in [0.25, 0.5, 0.75, 1.0]:
			_camera._input(_touch_drag(first_id + 1, second.lerp(final_second, fraction)))
			await process_frame
			_expect(_all_feedback_idle(), "%s should remain silent throughout motion" % description)
	else:
		_camera._input(_touch_drag(first_id + 1, final_second))
	_camera._input(_touch_event(first_id + 1, final_second, false))
	_camera._input(_touch_event(first_id, first, false))
	_expect(_capture_all_plots() == before, "%s should not mutate or scale any plot" % description)
	_expect(_total_activations() == activations_before and _all_feedback_idle(), "%s should produce zero plot clicks or actions" % description)


func _verify_multitouch_and_pan_silence() -> void:
	_reset_world_input()
	var held_plot := _plots[1]
	var held_point := _plot_hit_screen_position(held_plot)
	var before := _capture_all_plots()
	var activations_before := _total_activations()
	_press_plot_touch(held_plot, _touch_event(60, held_point, true))
	await create_timer(0.06).timeout
	_camera._input(_touch_event(61, held_point + Vector2(80.0, 20.0), true))
	await process_frame
	_camera._input(_touch_event(61, held_point + Vector2(80.0, 20.0), false))
	_camera._input(_touch_event(60, held_point, false))
	_expect(_capture_all_plots() == before and _total_activations() == activations_before, "second finger after a held first touch should cancel silently")
	_expect(_all_feedback_idle(), "stationary two-finger gesture should have zero click or scale feedback")

	_reset_world_input()
	var pan_plot := _plots[2]
	var pan_point := _plot_hit_screen_position(pan_plot)
	before = _capture_all_plots()
	activations_before = _total_activations()
	_press_plot_touch(pan_plot, _touch_event(70, pan_point, true))
	_camera._input(_touch_drag(70, pan_point + Vector2(13.0, 0.0)))
	_camera._input(_touch_event(70, pan_point + Vector2(13.0, 0.0), false))
	_expect(_capture_all_plots() == before and _total_activations() == activations_before, "one-finger pan from a plot should cause no crop action or feedback")
	_expect(_all_feedback_idle(), "one-finger pan should finish with every plot unscaled and silent")

	_reset_world_input()
	var extra_plot := _plots[3]
	var extra_point := _plot_hit_screen_position(extra_plot)
	before = _capture_all_plots()
	activations_before = _total_activations()
	_press_plot_touch(extra_plot, _touch_event(80, extra_point, true))
	_camera._input(_touch_event(81, extra_point + Vector2(-90.0, -90.0), true))
	_camera._input(_touch_event(82, extra_point + Vector2(90.0, -90.0), true))
	_camera._input(_touch_event(81, extra_point + Vector2(-90.0, -90.0), false))
	_camera._input(_touch_event(80, extra_point, false))
	var extra_hit_area := extra_plot.get_node(^"PlotBase/HitArea") as Area2D
	_expect(not extra_hit_area.input_pickable, "third finger should keep plot input suppressed after the original pinch pair releases")
	_camera._input(_touch_event(82, extra_point + Vector2(90.0, -90.0), false))
	_expect(extra_hit_area.input_pickable, "plot input should resume when the final involved finger releases")
	_expect(_capture_all_plots() == before and _total_activations() == activations_before, "extra fingers should never create a plot action")
	_expect(_all_feedback_idle(), "extra fingers should remain silent and leave no scale residue")
	_perform_touch_tap(extra_plot, 83, "first tap after extra-finger cancellation")


func _verify_threshold_and_release_rules() -> void:
	_reset_world_input()
	var plot := _plots[0]
	var point := _plot_hit_screen_position(plot)
	var state_before := _capture_plot_state(plot)
	var before := _activation_count(plot)
	_press_plot_touch(plot, _touch_event(90, point, true))
	_camera._input(_touch_drag(90, point + Vector2(PAN_THRESHOLD, 0.0)))
	_camera._input(_touch_event(90, point + Vector2(PAN_THRESHOLD, 0.0), false))
	_expect(_activation_count(plot) == before + 1 and _audio(plot).playing, "exactly 12 logical pixels should remain a confirmed tap")
	_expect(_capture_plot_state(plot) == state_before, "12-pixel confirmed tap on a growing plot should not mutate its crop")
	_cancel_feedback()

	var all_before := _capture_all_plots()
	var total_before := _total_activations()
	_press_plot_touch(plot, _touch_event(91, point, true))
	_camera._input(_touch_drag(91, point + Vector2(12.01, 0.0)))
	_camera._input(_touch_event(91, point + Vector2(12.01, 0.0), false))
	_expect(_capture_all_plots() == all_before and _total_activations() == total_before and _all_feedback_idle(), "movement above 12 logical pixels should cancel silently")

	_reset_world_input()
	var edge_world := _plot_hit_world_position(plot) + Vector2(115.0, 0.0)
	var edge_screen := _world_to_screen(edge_world)
	all_before = _capture_all_plots()
	total_before = _total_activations()
	_press_plot_touch(plot, _touch_event(92, edge_screen, true))
	_camera._input(_touch_event(92, edge_screen + Vector2(2.0, 0.0), false))
	_expect(_capture_all_plots() == all_before and _total_activations() == total_before and _all_feedback_idle(), "release outside the original plot should cancel even below the pan threshold")


func _verify_focus_visibility_and_scene_recovery() -> void:
	var plot := _plots[1]
	_cancel_then_recover(plot, 100, "focus loss", func() -> void:
		plot._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
		_camera._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	)
	_cancel_then_recover(plot, 110, "visibility loss", func() -> void:
		_camera.hide()
		_camera.show()
	)

	_reset_world_input()
	var point := _plot_hit_screen_position(plot)
	var before := _activation_count(plot)
	_press_plot_touch(plot, _touch_event(120, point, true))
	var layer := plot.get_parent()
	layer.remove_child(plot)
	layer.add_child(plot)
	_camera._input(_touch_event(120, point, false))
	_expect(_activation_count(plot) == before and plot.scale == Vector2.ONE, "scene exit should cancel its pending touch silently")
	_perform_touch_tap(plot, 121, "first tap after scene cancellation")


func _cancel_then_recover(plot: Node, touch_id: int, description: String, cancel_action: Callable) -> void:
	_reset_world_input()
	var point := _plot_hit_screen_position(plot)
	var before := _activation_count(plot)
	_press_plot_touch(plot, _touch_event(touch_id, point, true))
	cancel_action.call()
	_camera._input(_touch_event(touch_id, point, false))
	_expect(_activation_count(plot) == before and plot.scale == Vector2.ONE and not _audio(plot).playing, "%s should cancel silently" % description)
	_perform_touch_tap(plot, touch_id + 1, "first tap after %s" % description)


func _verify_pulse_interruption() -> void:
	_reset_world_input()
	var plot := _plots[2]
	var before := _activation_count(plot)
	_perform_touch_tap(plot, 130, "pulse interruption setup", false)
	_advance_pulse(plot, 0.025)
	_expect(not plot.scale.is_equal_approx(Vector2.ONE), "confirmed pulse should be in flight before interruption")
	_camera._input(_touch_event(131, Vector2(40.0, 40.0), true))
	_camera._input(_touch_event(132, Vector2(140.0, 140.0), true))
	_expect(plot.scale == Vector2.ONE, "new camera gesture should kill an in-flight pulse and restore exact scale")
	_expect(_activation_count(plot) == before + 1, "pulse interruption must not undo the already confirmed action")
	_camera._input(_touch_event(132, Vector2(140.0, 140.0), false))
	_camera._input(_touch_event(131, Vector2(40.0, 40.0), false))
	_perform_touch_tap(plot, 133, "first tap after pulse interruption")


func _verify_mouse_parity() -> void:
	_reset_world_input()
	var plot := _plots[3]
	var point := _plot_hit_screen_position(plot)
	var before := _activation_count(plot)
	_camera._input(_mouse_button(point, MOUSE_BUTTON_LEFT, true))
	_emit_picker_event(plot, _mouse_button(point, MOUSE_BUTTON_LEFT, true))
	_expect(_activation_count(plot) == before and plot.scale == Vector2.ONE and not _audio(plot).playing, "left mouse-down should remain a silent possible tap")
	_camera._input(_mouse_button(point + Vector2(12.0, 0.0), MOUSE_BUTTON_LEFT, false))
	_expect(_activation_count(plot) == before + 1 and _audio(plot).playing, "left mouse release at 12 pixels should confirm once")
	_cancel_feedback()

	var all_before := _capture_all_plots()
	var total_before := _total_activations()
	_camera._input(_mouse_button(point, MOUSE_BUTTON_LEFT, true))
	_emit_picker_event(plot, _mouse_button(point, MOUSE_BUTTON_LEFT, true))
	_camera._input(_mouse_motion(point + Vector2(12.01, 0.0)))
	_camera._input(_mouse_button(point + Vector2(12.01, 0.0), MOUSE_BUTTON_LEFT, false))
	_expect(_capture_all_plots() == all_before and _total_activations() == total_before and _all_feedback_idle(), "left mouse motion above threshold should cancel silently")

	_camera._input(_mouse_button(point, MOUSE_BUTTON_MIDDLE, true))
	_camera._input(_mouse_motion(point + Vector2(40.0, 40.0)))
	_camera._input(_mouse_button(point + Vector2(40.0, 40.0), MOUSE_BUTTON_MIDDLE, false))
	_camera._input(_mouse_button(point, MOUSE_BUTTON_WHEEL_UP, true))
	_expect(_capture_all_plots() == all_before and _total_activations() == total_before and _all_feedback_idle(), "middle drag and wheel zoom should never click or mutate plots")


func _perform_touch_tap(plot: Node, touch_id: int, description: String, finish_pulse := true) -> void:
	_reset_world_input()
	var point := _plot_hit_screen_position(plot)
	var before := _activation_count(plot)
	_press_plot_touch(plot, _touch_event(touch_id, point, true))
	_camera._input(_touch_event(touch_id, point, false))
	_expect(_activation_count(plot) == before + 1 and _audio(plot).playing, "%s should click and activate exactly once" % description)
	if finish_pulse:
		_advance_pulse(plot, 0.1)
		_expect(plot.scale == Vector2.ONE, "%s should restore exact scale" % description)


func _reset_world_input() -> void:
	_camera._clear_input_state()
	_camera.zoom = Vector2.ONE
	_camera.position = CENTER
	_camera.rotation = 0.0
	_camera._clamp_camera_position()
	_cancel_feedback()


func _cancel_feedback() -> void:
	for plot in _plots:
		plot.call("_discard_gesture")
		_audio(plot).stop()


func _all_feedback_idle() -> bool:
	for plot in _plots:
		if plot.scale != Vector2.ONE or _audio(plot).playing:
			return false
	return true


func _capture_all_plots() -> Array:
	var result: Array = []
	for plot in _plots:
		result.append(_capture_plot_state(plot))
	return result


func _capture_plot_state(plot: Node) -> Array:
	return [
		plot.get_lifecycle_state(), plot.get_visual_state(), plot.get_current_crop_id(),
		plot.get_last_harvested_crop_id(), plot.get_started_at_utc(), plot.get_ready_at_utc(),
		plot.position, plot.scale, plot.rotation,
	]


func _total_activations() -> int:
	var total := 0
	for count in _activation_counts.values():
		total += int(count)
	return total


func _activation_count(plot: Node) -> int:
	return int(_activation_counts.get(plot.get_instance_id(), 0))


func _plot_hit_world_position(plot: Node) -> Vector2:
	var hit_shape := plot.get_node(^"PlotBase/HitArea/CollisionShape2D") as CollisionShape2D
	return hit_shape.global_position


func _plot_hit_screen_position(plot: Node) -> Vector2:
	return _world_to_screen(_plot_hit_world_position(plot))


func _world_to_screen(world_point: Vector2) -> Vector2:
	return (world_point - _camera.position) * _camera.zoom.x + VIEWPORT_SIZE * 0.5


func _press_plot_touch(plot: Node, event: InputEventScreenTouch) -> void:
	_camera._input(event)
	_emit_picker_event(plot, event)


func _emit_picker_event(plot: Node, event: InputEvent) -> void:
	var hit_area := plot.get_node(^"PlotBase/HitArea") as Area2D
	if hit_area.input_pickable:
		hit_area.input_event.emit(plot.get_viewport(), event, 0)


func _advance_pulse(plot: Node, seconds: float) -> void:
	var tween := plot.get("_pulse_tween") as Tween
	_expect(tween != null, "confirmed feedback should own one active pulse tween")
	if tween != null:
		tween.custom_step(seconds)


func _audio(plot: Node) -> AudioStreamPlayer:
	return plot.get_node(^"PlotBase/ActivationAudio") as AudioStreamPlayer


func _touch_event(index: int, position: Vector2, pressed: bool, canceled := false) -> InputEventScreenTouch:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = position
	event.pressed = pressed
	event.canceled = canceled
	return event


func _touch_drag(index: int, position: Vector2) -> InputEventScreenDrag:
	var event := InputEventScreenDrag.new()
	event.index = index
	event.position = position
	return event


func _mouse_button(position: Vector2, button_index: MouseButton, pressed: bool) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.position = position
	event.button_index = button_index
	event.pressed = pressed
	return event


func _mouse_motion(position: Vector2) -> InputEventMouseMotion:
	var event := InputEventMouseMotion.new()
	event.position = position
	return event


func _stop_all_audio() -> void:
	for plot in _plots:
		var audio := _audio(plot)
		audio.stop()
		audio.stream = null


func _on_plot_activated(plot: Node) -> void:
	var plot_id := plot.get_instance_id()
	_activation_counts[plot_id] = int(_activation_counts.get(plot_id, 0)) + 1


func _expect(condition: bool, description: String) -> void:
	if not condition:
		_failures.append(description)
