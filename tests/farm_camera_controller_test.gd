extends SceneTree

const CameraScript = preload("res://scripts/farm/farm_camera_controller.gd")
const FarmWorldScript = preload("res://scripts/farm/farm_world.gd")
const FarmPlotScript = preload("res://scripts/farm/farm_plot.gd")
const ClockScript = preload("res://scripts/platform/session_utc_clock.gd")
const FARM_WORLD_SCENE := preload("res://scenes/farm/farm_world.tscn")
const VIEWPORT_SIZE := Vector2(540.0, 960.0)
const FARM_RECT := Rect2(Vector2.ZERO, VIEWPORT_SIZE)
const CENTER := Vector2(270.0, 480.0)
const PRIMARY_CROP_ID := &"sunwheat"


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
var _camera_cancel_count := 0
var _planted_events: Array = []
var _harvested_events: Array = []


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
	_camera.plot_gesture_cancel_requested.connect(_on_camera_cancel_requested)
	(_world.get_node(^"InteractionController") as FarmPlotInteractionController).crop_planted.connect(_on_crop_planted)
	(_world.get_node(^"InteractionController") as FarmPlotInteractionController).crop_harvested.connect(_on_crop_harvested)

	_verify_structure_and_default_framing()
	_verify_zoom_limits_and_pinch_anchor()
	_verify_pan_threshold_and_edges()
	_verify_touch_arbitration_and_cleanup()
	_verify_mouse_parity()

	_stop_plot_audio()
	await create_timer(0.25).timeout
	_world.queue_free()
	await process_frame
	await process_frame
	_finish_test()


func _finish_test() -> void:
	if not _failures.is_empty():
		for failure in _failures:
			printerr("TEST FAILURE: %s" % failure)
		quit(1)
		return
	print("FARM_CAMERA_CONTROLLER_TEST_PASS")
	quit()


func _verify_structure_and_default_framing() -> void:
	_expect(_world.get("_farm_camera_controller") == _camera, "FarmWorld should own the supplied camera controller")
	_expect(_camera.get_parent() == _world and _camera.name == "FarmCameraController", "FarmWorld should own exactly named runtime camera controller")
	var cameras := _world.find_children("*", "Camera2D", true, false)
	_expect(cameras.size() == 1 and cameras[0] == _camera, "FarmWorld should contain exactly one Camera2D controller")
	_expect(_camera.enabled, "farm camera should be enabled")
	_expect(_camera.position == CENTER, "default camera should center on farm point (270, 480)")
	_expect(_camera.zoom == Vector2.ONE and _camera.rotation == 0.0, "default camera should use zoom 1.0 and no rotation")
	_expect(_visible_world_rect(_camera).is_equal_approx(FARM_RECT), "default camera should show the complete farm rect")
	_expect(_plots.size() == 4, "camera test should use all four real FarmPlots")
	for plot in _plots:
		var base := plot.get_node(^"PlotBase") as Sprite2D
		_expect(FARM_RECT.encloses(_world_sprite_rect(base)), "%s should remain fully visible at default framing" % plot.name)
		_expect(plot.get_lifecycle_state() == FarmPlotScript.VisualState.EMPTY, "%s should begin EMPTY" % plot.name)
	_expect(_camera.find_children("*", "AudioStreamPlayer", true, false).is_empty(), "camera controller should add no sound feedback")
	var source := FileAccess.get_file_as_string("res://scripts/farm/farm_camera_controller.gd")
	for forbidden_text in ["Time.", "plant_crop", "harvest_crop", "replant_last_crop", "get_crop", "now_utc"]:
		_expect(not source.contains(forbidden_text), "camera controller should not contain gameplay or clock dependency '%s'" % forbidden_text)


func _verify_zoom_limits_and_pinch_anchor() -> void:
	_reset_camera()
	var pointer := Vector2(390.0, 390.0)
	var world_before := _screen_to_world(pointer)
	_camera._input(_mouse_button(pointer, MOUSE_BUTTON_WHEEL_UP, true))
	_expect(is_equal_approx(_camera.zoom.x, 1.1), "mouse wheel should zoom in by exactly 0.1")
	_expect(_screen_to_world(pointer).is_equal_approx(world_before), "mouse wheel zoom should preserve the world point beneath pointer")
	for step in 20:
		_camera._input(_mouse_button(pointer, MOUSE_BUTTON_WHEEL_UP, true))
	_expect(_camera.zoom == Vector2.ONE * 2.0, "wheel zoom should clamp continuously at 2.0")
	for step in 30:
		_camera._input(_mouse_button(pointer, MOUSE_BUTTON_WHEEL_DOWN, true))
	_expect(_camera.zoom == Vector2.ONE and _camera.position == CENTER, "wheel zoom should clamp at 1.0 and recenter full farm")

	_reset_camera()
	var first := Vector2(200.0, 400.0)
	var second := Vector2(340.0, 560.0)
	var midpoint := (first + second) * 0.5
	var anchored_world := _screen_to_world(midpoint)
	var cancels_before := _camera_cancel_count
	_camera._input(_touch_event(3, first, true))
	_camera._input(_touch_event(7, second, true))
	_expect(_camera_cancel_count == cancels_before + 1, "introducing second touch should request plot cancellation once")
	var moved_second := Vector2(410.0, 630.0)
	_camera._input(_touch_drag(7, moved_second))
	var moved_midpoint := (first + moved_second) * 0.5
	_expect(_camera.zoom.x > 1.0 and _camera.zoom.x < 2.0, "pinch separation should proportionally change zoom")
	_expect(_screen_to_world(moved_midpoint).is_equal_approx(anchored_world), "pinch should keep its anchored world point beneath moving midpoint")
	_camera._input(_touch_drag(7, Vector2(540.0, 960.0)))
	_expect(_camera.zoom == Vector2.ONE * 2.0, "outward pinch should clamp at 2.0")
	_camera._input(_touch_event(7, Vector2(540.0, 960.0), false))
	_camera._input(_touch_event(3, first, false))

	_camera.zoom = Vector2.ONE * 2.0
	_camera.position = CENTER
	_camera._clamp_camera_position()
	var wide_first := Vector2(100.0, 300.0)
	var wide_second := Vector2(440.0, 660.0)
	_camera._input(_touch_event(11, wide_first, true))
	_camera._input(_touch_event(15, wide_second, true))
	_camera._input(_touch_drag(15, Vector2(120.0, 320.0)))
	_expect(_camera.zoom == Vector2.ONE and _camera.position == CENTER, "inward pinch should clamp at 1.0 and restore centered farm")
	_camera._input(_touch_event(15, Vector2(120.0, 320.0), false))
	_camera._input(_touch_event(11, wide_first, false))


func _verify_pan_threshold_and_edges() -> void:
	_reset_camera()
	_camera.zoom = Vector2.ONE * 2.0
	_camera.position = CENTER
	var start := CENTER
	_camera._input(_touch_event(21, start, true))
	_camera._input(_touch_drag(21, start + Vector2(11.0, 0.0)))
	_expect(_camera.position == CENTER, "movement at or below 12 logical pixels should not pan")
	var cancels_before := _camera_cancel_count
	_camera._input(_touch_drag(21, start + Vector2(13.0, 0.0)))
	_expect(_camera.position.x < CENTER.x, "farm should follow rightward finger movement")
	_expect(_camera_cancel_count == cancels_before + 1, "crossing pan threshold should cancel plot activation once")
	var released_position := _camera.position
	_camera._input(_touch_event(21, start + Vector2(13.0, 0.0), false))
	_camera._input(_touch_drag(21, start + Vector2(100.0, 0.0)))
	_expect(_camera.position == released_position, "camera should not move after touch release")

	_reset_camera()
	cancels_before = _camera_cancel_count
	_camera._input(_touch_event(22, start, true))
	_camera._input(_touch_drag(22, start + Vector2(100.0, 0.0)))
	_expect(_camera.position == CENTER, "one-finger motion at zoom 1.0 should never displace farm")
	_expect(_camera_cancel_count == cancels_before + 1, "zoom-1 drag crossing threshold should still cancel plot tap")
	_camera._input(_touch_event(22, start + Vector2(100.0, 0.0), false))

	_camera.zoom = Vector2.ONE * 2.0
	_camera.position = CENTER
	_camera._clamp_camera_position()
	_middle_drag(start, start + Vector2(2000.0, 0.0))
	_expect(is_equal_approx(_camera.position.x, 135.0), "rightward farm drag should clamp at stable left camera edge")
	var stable_edge := _camera.position
	_middle_drag(start, start + Vector2(2000.0, 0.0))
	_expect(_camera.position == stable_edge, "repeated left-edge pressure should accumulate no drift")
	_middle_drag(start, start - Vector2(2000.0, 0.0))
	_expect(is_equal_approx(_camera.position.x, 405.0), "leftward farm drag should clamp at stable right camera edge")
	_middle_drag(start, start + Vector2(0.0, 2000.0))
	_expect(is_equal_approx(_camera.position.y, 240.0), "downward farm drag should clamp at stable top camera edge")
	_middle_drag(start, start - Vector2(0.0, 2000.0))
	_expect(is_equal_approx(_camera.position.y, 720.0), "upward farm drag should clamp at stable bottom camera edge")
	_expect(FARM_RECT.encloses(_visible_world_rect(_camera)), "every clamped camera edge should keep visible rect inside meadow")


func _verify_touch_arbitration_and_cleanup() -> void:
	_reset_camera()
	var drag_plot := _plots[0]
	var drag_position := _plot_hit_screen_position(drag_plot)
	var drag_snapshot := _capture_plot(drag_plot)
	var base_scale: Vector2 = drag_plot.scale
	var audio := drag_plot.get_node(^"PlotBase/ActivationAudio") as AudioStreamPlayer
	audio.stop()
	_press_plot_touch(drag_plot, _touch_event(31, drag_position, true))
	_expect(drag_plot.scale == base_scale and not audio.playing, "plot-origin touch-down should remain silent and unscaled before classification")
	var drag_event := _touch_drag(31, drag_position + Vector2(13.0, 0.0))
	_camera._input(drag_event)
	_expect(drag_plot.scale == base_scale, "crossing pan threshold should restore exact plot scale")
	var drag_release := _touch_event(31, drag_position + Vector2(13.0, 0.0), false)
	_camera._input(drag_release)
	_expect(_capture_plot(drag_plot) == drag_snapshot, "camera drag should cause no plot activation or crop mutation")

	var pinch_plot := _plots[1]
	var pinch_position := _plot_hit_screen_position(pinch_plot)
	var pinch_snapshot := _capture_plot(pinch_plot)
	base_scale = pinch_plot.scale
	_press_plot_touch(pinch_plot, _touch_event(41, pinch_position, true))
	_camera._input(_touch_event(45, pinch_position + Vector2(100.0, 100.0), true))
	var pinch_hit_area := pinch_plot.get_node(^"PlotBase/HitArea") as Area2D
	_expect(not pinch_hit_area.input_pickable, "camera pinch should suppress plot picking for the complete gesture")
	_emit_picker_event(pinch_plot, _touch_event(45, pinch_position, true))
	_expect(pinch_plot.scale == base_scale, "second touch should cancel and restore a pressed plot")
	_camera._input(_touch_drag(45, pinch_position + Vector2(180.0, 180.0)))
	_camera._input(_touch_event(45, pinch_position + Vector2(180.0, 180.0), false))
	_camera._input(_touch_event(41, pinch_position, false))
	_expect(pinch_hit_area.input_pickable, "plot picking should resume after every pinch touch releases")
	_expect(_capture_plot(pinch_plot) == pinch_snapshot, "pinch should cause no plot activation or crop mutation")

	_reset_camera()
	var extra_plot := _plots[2]
	var extra_position := _plot_hit_screen_position(extra_plot)
	var extra_snapshot := _capture_plot(extra_plot)
	_camera._input(_touch_event(51, Vector2(100.0, 200.0), true))
	_camera._input(_touch_event(55, Vector2(440.0, 760.0), true))
	var pair_before: Array = (_camera.get("_pinch_touch_ids") as Array).duplicate()
	_camera._input(_touch_event(59, extra_position, true))
	_emit_picker_event(extra_plot, _touch_event(59, extra_position, true))
	_expect((_camera.get("_pinch_touch_ids") as Array) == pair_before, "third finger should not replace active pinch pair")
	_expect(extra_plot.scale == Vector2.ONE, "third-finger plot press should be canceled without stuck feedback")
	_camera._input(_touch_event(59, extra_position, false))
	_expect(_capture_plot(extra_plot) == extra_snapshot, "third finger should not activate or mutate plot")
	_camera._input(_touch_event(55, Vector2(440.0, 760.0), false))
	_camera._input(_touch_event(51, Vector2(100.0, 200.0), false))

	var cancel_plot := _plots[3]
	var cancel_position := _plot_hit_screen_position(cancel_plot)
	_press_plot_touch(cancel_plot, _touch_event(61, cancel_position, true))
	var canceled_release := _touch_event(61, cancel_position, false, true)
	_camera._input(canceled_release)
	_expect(cancel_plot.scale == Vector2.ONE, "touch cancellation should restore exact plot scale")
	_expect((_camera.get("_touch_positions") as Dictionary).is_empty(), "touch cancellation should clear camera touch state")

	_press_plot_touch(cancel_plot, _touch_event(62, cancel_position, true))
	cancel_plot._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	_camera._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	_expect(cancel_plot.scale == Vector2.ONE and (_camera.get("_touch_positions") as Dictionary).is_empty(), "focus loss should restore plot and camera input state")


func _verify_mouse_parity() -> void:
	_reset_camera()
	var plot := _plots[3]
	var click_position := _plot_hit_screen_position(plot)
	var events_before := _planted_events.size()
	_camera._input(_mouse_button(click_position, MOUSE_BUTTON_LEFT, true))
	_emit_picker_event(plot, _mouse_button(click_position, MOUSE_BUTTON_LEFT, true))
	_camera._input(_mouse_button(click_position, MOUSE_BUTTON_LEFT, false))
	_expect(_planted_events.size() == events_before + 1, "ordinary left click should retain exactly one successful plot action")
	_expect(plot.get_lifecycle_state() == FarmPlotScript.VisualState.GROWING and plot.get_current_crop_id() == PRIMARY_CROP_ID, "unchanged left click should plant selected Sunwheat")

	var planted_snapshot := _capture_plot(plot)
	_camera._input(_mouse_button(CENTER, MOUSE_BUTTON_WHEEL_UP, true))
	_middle_drag(CENTER, CENTER + Vector2(100.0, 100.0))
	_expect(_capture_plot(plot) == planted_snapshot, "mouse wheel and middle drag should not mutate crop state")

	var ready_plot := _plots[0]
	_expect(ready_plot.plant_crop(PRIMARY_CROP_ID, 1000), "zoomed tap setup should plant a crop")
	ready_plot.update_growth(ready_plot.get_ready_at_utc())
	_expect(ready_plot.get_lifecycle_state() == FarmPlotScript.VisualState.READY, "zoomed tap setup should make crop READY")
	_camera.zoom = Vector2.ONE * 2.0
	_camera.position = CENTER
	_camera._clamp_camera_position()
	var ready_position := _plot_hit_screen_position(ready_plot)
	var harvests_before := _harvested_events.size()
	_press_plot_touch(ready_plot, _touch_event(71, ready_position, true))
	_camera._input(_touch_event(71, ready_position, false))
	_expect(_harvested_events.size() == harvests_before + 1, "one normal touch tap while zoomed should harvest exactly once")
	_expect(ready_plot.get_lifecycle_state() == FarmPlotScript.VisualState.EMPTY, "zoomed READY tap should complete its harvest")


func _reset_camera() -> void:
	_camera._clear_input_state()
	_camera.zoom = Vector2.ONE
	_camera.position = CENTER
	_camera.rotation = 0.0
	_camera._clamp_camera_position()


func _middle_drag(start: Vector2, finish: Vector2) -> void:
	_camera._input(_mouse_button(start, MOUSE_BUTTON_MIDDLE, true))
	_camera._input(_mouse_motion(finish))
	_camera._input(_mouse_button(finish, MOUSE_BUTTON_MIDDLE, false))


func _visible_world_rect(camera: Camera2D) -> Rect2:
	var size := VIEWPORT_SIZE / camera.zoom.x
	return Rect2(camera.position - size * 0.5, size)


func _screen_to_world(screen_point: Vector2) -> Vector2:
	return _camera.position + (screen_point - VIEWPORT_SIZE * 0.5) / _camera.zoom.x


func _plot_hit_screen_position(plot: Node) -> Vector2:
	var hit_shape := plot.get_node(^"PlotBase/HitArea/CollisionShape2D") as CollisionShape2D
	var world_point := hit_shape.global_position
	return (world_point - _camera.position) * _camera.zoom.x + VIEWPORT_SIZE * 0.5


func _world_sprite_rect(sprite: Sprite2D) -> Rect2:
	var local_rect := sprite.get_rect()
	return Rect2(sprite.to_global(local_rect.position), local_rect.size * sprite.global_scale.abs())


func _capture_plot(plot: Node) -> Array:
	return [
		plot.get_lifecycle_state(), plot.get_visual_state(),
		plot.get_current_crop_id(), plot.get_last_harvested_crop_id(),
		plot.get_started_at_utc(), plot.get_ready_at_utc(),
		plot.position, plot.scale, plot.rotation,
	]


func _emit_picker_event(plot: Node, event: InputEvent) -> void:
	var hit_area := plot.get_node(^"PlotBase/HitArea") as Area2D
	if hit_area.input_pickable:
		hit_area.input_event.emit(plot.get_viewport(), event, 0)


func _press_plot_touch(plot: Node, event: InputEventScreenTouch) -> void:
	_camera._input(event)
	_emit_picker_event(plot, event)


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


func _stop_plot_audio() -> void:
	for plot in _plots:
		var audio := plot.get_node(^"PlotBase/ActivationAudio") as AudioStreamPlayer
		audio.stop()
		audio.stream = null


func _on_camera_cancel_requested() -> void:
	_camera_cancel_count += 1


func _on_crop_planted(plot: Node, crop_id: StringName) -> void:
	_planted_events.append([plot, crop_id])


func _on_crop_harvested(plot: Node, crop_id: StringName) -> void:
	_harvested_events.append([plot, crop_id])


func _expect(condition: bool, description: String) -> void:
	if not condition:
		_failures.append(description)
