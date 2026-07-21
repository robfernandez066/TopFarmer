extends SceneTree

const FarmPlotScript = preload("res://scripts/farm/farm_plot.gd")
const FARM_PLOT_SCENE := preload("res://scenes/farm/farm_plot.tscn")
const AUDIO_PATH := "res://assets/audio/sfx/ui_tap_soft.wav"
const AUDIO_SHA256 := "359C8C98ECD48368F45B84D3A9B9D7E68CF3AC2FEFCDBF32367B8482DA76C9C7"
const AUDIO_BYTE_SIZE := 16596
const HIT_AREA_SIZE := Vector2(232.0, 216.0)
const HIT_SHAPE_POSITION := Vector2(0.0, -112.0)
const PRESS_SCALE_FACTOR := 0.97
const PRIMARY_CROP_ID := &"sunwheat"

var _failures: Array[String] = []
var _activation_count := 0


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var farm_plot := FARM_PLOT_SCENE.instantiate()
	root.add_child(farm_plot)
	farm_plot.position = Vector2(31.0, 47.0)
	farm_plot.rotation = 0.125
	farm_plot.scale = Vector2(1.25, 0.8)
	farm_plot.connect(&"activated", _on_activated)

	_verify_structure_and_audio(farm_plot)
	_verify_valid_gestures_in_all_states(farm_plot)
	_verify_touch_authority_and_rejections(farm_plot)
	_verify_cancellation_and_safeguards(farm_plot)
	_verify_repeated_gestures(farm_plot)
	_verify_tree_exit_restoration()
	(farm_plot.get_node(^"PlotBase/ActivationAudio") as AudioStreamPlayer).stop()
	farm_plot.free()

	if not _failures.is_empty():
		for failure in _failures:
			printerr("TEST FAILURE: %s" % failure)
		quit(1)
		return
	call_deferred("_finish_success")


func _finish_success() -> void:
	await create_timer(0.25).timeout
	await process_frame
	print("FARM_PLOT_TOUCH_FEEDBACK_TEST_PASS")
	quit()


func _verify_structure_and_audio(farm_plot: Node) -> void:
	_expect(farm_plot.has_signal(&"activated"), "FarmPlot should declare activated")
	_expect(farm_plot.get_child_count() == 3, "existing three direct visual children should remain exact")
	var hit_areas := farm_plot.find_children("*", "Area2D", true, false)
	_expect(hit_areas.size() == 1, "FarmPlot should contain exactly one Area2D")
	if hit_areas.size() != 1:
		return
	var hit_area := hit_areas[0] as Area2D
	_expect(hit_area.input_pickable, "hit area should be input-pickable")
	_expect(farm_plot.to_local(hit_area.global_position).is_equal_approx(Vector2.ZERO), "hit area should resolve to the FarmPlot ground-contact origin")
	_expect(hit_area.get_child_count() == 1, "hit area should contain exactly one child")
	var hit_shape := hit_area.get_child(0) as CollisionShape2D
	_expect(hit_shape != null, "hit area child should be CollisionShape2D")
	if hit_shape != null:
		_expect(hit_shape.position == HIT_SHAPE_POSITION, "collision shape position should be exactly (0, -112)")
		var rectangle := hit_shape.shape as RectangleShape2D
		_expect(rectangle != null, "collision shape should use RectangleShape2D")
		if rectangle != null:
			_expect(rectangle.size == HIT_AREA_SIZE, "hit rectangle should be exactly (232, 216)")

	var audio_players := farm_plot.find_children("*", "AudioStreamPlayer", true, false)
	_expect(audio_players.size() == 1, "FarmPlot should contain exactly one non-positional AudioStreamPlayer")
	if audio_players.size() != 1:
		return
	var audio := audio_players[0] as AudioStreamPlayer
	_expect(audio.stream != null and audio.stream.resource_path == AUDIO_PATH, "activation audio should use only the exact runtime WAV")
	_expect(not audio.autoplay, "activation audio autoplay should remain disabled")
	_expect(audio.volume_db == 0.0, "activation audio volume should remain default")
	_expect(audio.pitch_scale == 1.0, "activation audio pitch should remain default")
	var wav := audio.stream as AudioStreamWAV
	_expect(wav != null, "activation audio should import as AudioStreamWAV")
	if wav != null:
		_expect(wav.loop_mode == AudioStreamWAV.LOOP_DISABLED, "activation audio looping should be disabled")
		_expect(wav.format == AudioStreamWAV.FORMAT_16_BITS, "activation audio should remain 16-bit PCM")
		_expect(wav.stereo, "activation audio should remain stereo")
		_expect(wav.mix_rate == 44100, "activation audio should remain at 44.1 kHz")
	var audio_file := FileAccess.open(AUDIO_PATH, FileAccess.READ)
	_expect(audio_file != null, "runtime activation WAV should exist")
	if audio_file != null:
		_expect(audio_file.get_length() == AUDIO_BYTE_SIZE, "runtime activation WAV should preserve exact byte size")
	_expect(FileAccess.get_sha256(AUDIO_PATH).to_upper() == AUDIO_SHA256, "runtime activation WAV should preserve approved SHA-256")


func _verify_valid_gestures_in_all_states(farm_plot: Node) -> void:
	_verify_lifecycle_state(farm_plot, FarmPlotScript.VisualState.EMPTY, "EMPTY before touch")
	_perform_valid_touch(farm_plot, 0, "EMPTY touch")
	_verify_lifecycle_state(farm_plot, FarmPlotScript.VisualState.EMPTY, "EMPTY after touch")

	var balance := root.get_node_or_null(^"Balance")
	_expect(balance != null, "real Balance autoload should be present")
	if balance == null:
		return
	var crop_row: Dictionary = balance.call("get_crop", String(PRIMARY_CROP_ID))
	_expect(not crop_row.is_empty() and crop_row.has("growth_sec_eff"), "Balance should provide Sunwheat growth_sec_eff")
	if crop_row.is_empty() or not crop_row.has("growth_sec_eff"):
		return
	var growth_seconds := int(ceil(float(crop_row["growth_sec_eff"])))
	var start_time := 1000
	_expect(farm_plot.plant_crop(PRIMARY_CROP_ID, start_time), "test setup should plant Sunwheat")
	_verify_lifecycle_state(farm_plot, FarmPlotScript.VisualState.GROWING, "GROWING before mouse")
	_perform_valid_mouse(farm_plot, "GROWING mouse")
	_verify_lifecycle_state(farm_plot, FarmPlotScript.VisualState.GROWING, "GROWING after mouse")

	farm_plot.update_growth(start_time + growth_seconds)
	_verify_lifecycle_state(farm_plot, FarmPlotScript.VisualState.READY, "READY before touch")
	_perform_valid_touch(farm_plot, 2, "READY touch")
	_verify_lifecycle_state(farm_plot, FarmPlotScript.VisualState.READY, "READY after touch")


func _verify_touch_authority_and_rejections(farm_plot: Node) -> void:
	var inside_position: Vector2 = farm_plot.to_global(HIT_SHAPE_POSITION)
	var audio := farm_plot.get_node(^"PlotBase/ActivationAudio") as AudioStreamPlayer
	var original := _capture_plot(farm_plot)

	var before_count := _activation_count
	audio.stop()
	_emit_picker_event(farm_plot, _touch_event(3, inside_position, true))
	farm_plot._input(_touch_event(3, inside_position, false))
	_expect(_activation_count == before_count + 1, "authoritative touch should activate exactly once")
	var touch_count := _activation_count
	audio.stop()
	_emit_picker_event(farm_plot, _mouse_button(inside_position, MOUSE_BUTTON_LEFT, true, InputEvent.DEVICE_ID_EMULATION))
	farm_plot._input(_mouse_button(inside_position, MOUSE_BUTTON_LEFT, false, InputEvent.DEVICE_ID_EMULATION))
	_expect(_activation_count == touch_count, "emulated mouse after handled touch should not duplicate activation")
	_expect(not audio.playing, "emulated mouse should not duplicate the touch sound")
	_expect(_capture_plot(farm_plot) == original, "touch/mouse deduplication should not mutate plot state")

	before_count = _activation_count
	audio.stop()
	var base_scale: Vector2 = farm_plot.scale
	_emit_picker_event(farm_plot, _touch_event(4, inside_position, true))
	var pressed_scale: Vector2 = farm_plot.scale
	_emit_picker_event(farm_plot, _touch_event(5, inside_position, true))
	farm_plot._input(_touch_event(5, inside_position, false))
	_expect(farm_plot.scale == pressed_scale, "secondary finger should not alter accepted press feedback")
	farm_plot._input(_mouse_button(inside_position, MOUSE_BUTTON_LEFT, true))
	farm_plot._input(_mouse_button(inside_position, MOUSE_BUTTON_LEFT, false))
	_expect(farm_plot.scale == pressed_scale, "mouse fallback should be ignored while touch is active")
	farm_plot._input(_touch_event(4, inside_position, false))
	_expect(_activation_count == before_count + 1, "primary finger should remain the only activation")
	_expect(farm_plot.scale == base_scale, "primary touch release should restore exact scale")

	var invalid_events: Array[InputEvent] = [
		_mouse_button(inside_position, MOUSE_BUTTON_RIGHT, true),
		_mouse_button(inside_position, MOUSE_BUTTON_MIDDLE, true),
		_mouse_button(inside_position, MOUSE_BUTTON_WHEEL_UP, true),
		_key_event(),
	]
	for invalid_event in invalid_events:
		before_count = _activation_count
		audio.stop()
		_emit_picker_event(farm_plot, invalid_event)
		_expect(_activation_count == before_count, "non-primary input should not activate")
		_expect(not audio.playing, "non-primary input should not play feedback audio")
		_expect(_capture_plot(farm_plot) == original, "non-primary input should not mutate plot state")


func _verify_cancellation_and_safeguards(farm_plot: Node) -> void:
	var inside_position: Vector2 = farm_plot.to_global(HIT_SHAPE_POSITION)
	var outside_position: Vector2 = farm_plot.to_global(Vector2(HIT_AREA_SIZE.x, HIT_SHAPE_POSITION.y))
	var base_scale: Vector2 = farm_plot.scale
	var original := _capture_plot(farm_plot)
	var before_count := _activation_count

	_emit_picker_event(farm_plot, _touch_event(6, inside_position, true))
	farm_plot._input(_touch_event(6, outside_position, false))
	_expect(_activation_count == before_count, "touch release outside should cancel activation")
	_expect(farm_plot.scale == base_scale, "touch release outside should restore exact scale")
	_expect(_capture_plot(farm_plot) == original, "touch release outside should preserve plot state")

	_emit_picker_event(farm_plot, _touch_event(7, inside_position, true))
	farm_plot._input(_touch_drag(7, outside_position))
	_expect(farm_plot.scale == base_scale, "touch leaving hit area should restore scale immediately")
	farm_plot._input(_touch_event(7, inside_position, false))
	_expect(_activation_count == before_count, "touch returning after cancellation should not activate")

	_emit_picker_event(farm_plot, _touch_event(8, inside_position, true))
	farm_plot._input(_touch_event(8, inside_position, false, true))
	_expect(_activation_count == before_count, "cancelled touch release should not activate")
	_expect(farm_plot.scale == base_scale, "cancelled touch should restore exact scale")

	_emit_picker_event(farm_plot, _mouse_button(inside_position, MOUSE_BUTTON_LEFT, true))
	farm_plot._input(_mouse_motion(outside_position))
	_expect(farm_plot.scale == base_scale, "mouse leaving hit area should restore scale immediately")
	farm_plot._input(_mouse_button(inside_position, MOUSE_BUTTON_LEFT, false))
	_expect(_activation_count == before_count, "mouse returning after cancellation should not activate")

	_emit_picker_event(farm_plot, _mouse_button(inside_position, MOUSE_BUTTON_LEFT, true))
	farm_plot.hide()
	_expect(farm_plot.scale == base_scale, "becoming hidden should restore exact scale")
	farm_plot.show()
	farm_plot._input(_mouse_button(inside_position, MOUSE_BUTTON_LEFT, false))
	_expect(_activation_count == before_count, "hidden gesture should be discarded without activation")

	_emit_picker_event(farm_plot, _mouse_button(inside_position, MOUSE_BUTTON_LEFT, true))
	farm_plot._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	_expect(farm_plot.scale == base_scale, "focus loss should restore exact scale")
	farm_plot._input(_mouse_button(inside_position, MOUSE_BUTTON_LEFT, false))
	_expect(_activation_count == before_count, "focus-lost gesture should be discarded without activation")
	_expect(_capture_plot(farm_plot) == original, "all cancellation safeguards should preserve plot state")


func _verify_repeated_gestures(farm_plot: Node) -> void:
	var original := _capture_plot(farm_plot)
	var expected_count := _activation_count
	for gesture_index in 10:
		_perform_valid_mouse(farm_plot, "repeated mouse gesture %d" % (gesture_index + 1))
		expected_count += 1
		_expect(_activation_count == expected_count, "repeated gesture %d should activate exactly once" % (gesture_index + 1))
		_expect(_capture_plot(farm_plot) == original, "repeated gesture %d should not drift transform or nodes" % (gesture_index + 1))


func _verify_tree_exit_restoration() -> void:
	var farm_plot := FARM_PLOT_SCENE.instantiate()
	root.add_child(farm_plot)
	farm_plot.scale = Vector2(1.1, 0.9)
	farm_plot.connect(&"activated", _on_activated)
	var base_scale: Vector2 = farm_plot.scale
	var inside_position: Vector2 = farm_plot.to_global(HIT_SHAPE_POSITION)
	var before_count := _activation_count
	_emit_picker_event(farm_plot, _mouse_button(inside_position, MOUSE_BUTTON_LEFT, true))
	root.remove_child(farm_plot)
	_expect(farm_plot.scale == base_scale, "leaving the scene tree while pressed should restore exact scale")
	_expect(_activation_count == before_count, "tree exit should not activate")
	(farm_plot.get_node(^"PlotBase/ActivationAudio") as AudioStreamPlayer).stop()
	farm_plot.free()


func _perform_valid_touch(farm_plot: Node, touch_index: int, description: String) -> void:
	var inside_position: Vector2 = farm_plot.to_global(HIT_SHAPE_POSITION)
	var base_scale: Vector2 = farm_plot.scale
	var invariant_snapshot := _capture_invariants(farm_plot)
	var full_snapshot := _capture_plot(farm_plot)
	var before_count := _activation_count
	var audio := farm_plot.get_node(^"PlotBase/ActivationAudio") as AudioStreamPlayer
	audio.stop()
	_emit_picker_event(farm_plot, _touch_event(touch_index, inside_position, true))
	_expect(farm_plot.scale == base_scale * PRESS_SCALE_FACTOR, "%s should apply exact press scale" % description)
	_expect(farm_plot.position == full_snapshot[1] and farm_plot.rotation == full_snapshot[2], "%s should preserve ground origin and rotation during press" % description)
	_expect(audio.playing, "%s should play the soft click on press" % description)
	_expect(_capture_invariants(farm_plot) == invariant_snapshot, "%s press should not mutate lifecycle or visuals" % description)
	farm_plot._input(_touch_event(touch_index, inside_position, false))
	_expect(_activation_count == before_count + 1, "%s should emit exactly one activation on release" % description)
	_expect(_capture_plot(farm_plot) == full_snapshot, "%s release should restore exact transform without state drift" % description)


func _perform_valid_mouse(farm_plot: Node, description: String) -> void:
	var inside_position: Vector2 = farm_plot.to_global(HIT_SHAPE_POSITION)
	var base_scale: Vector2 = farm_plot.scale
	var invariant_snapshot := _capture_invariants(farm_plot)
	var full_snapshot := _capture_plot(farm_plot)
	var before_count := _activation_count
	var audio := farm_plot.get_node(^"PlotBase/ActivationAudio") as AudioStreamPlayer
	audio.stop()
	_emit_picker_event(farm_plot, _mouse_button(inside_position, MOUSE_BUTTON_LEFT, true))
	_expect(farm_plot.scale == base_scale * PRESS_SCALE_FACTOR, "%s should apply exact press scale" % description)
	_expect(farm_plot.position == full_snapshot[1] and farm_plot.rotation == full_snapshot[2], "%s should preserve ground origin and rotation during press" % description)
	_expect(audio.playing, "%s should play the soft click on press" % description)
	_expect(_capture_invariants(farm_plot) == invariant_snapshot, "%s press should not mutate lifecycle or visuals" % description)
	farm_plot._input(_mouse_button(inside_position, MOUSE_BUTTON_LEFT, false))
	_expect(_activation_count == before_count + 1, "%s should emit exactly one activation on release" % description)
	_expect(_capture_plot(farm_plot) == full_snapshot, "%s release should restore exact transform without state drift" % description)


func _verify_lifecycle_state(farm_plot: Node, expected_state: int, description: String) -> void:
	_expect(farm_plot.get_lifecycle_state() == expected_state, "%s lifecycle state should remain exact" % description)
	_expect(farm_plot.get_visual_state() == expected_state, "%s visual state should remain exact" % description)


func _capture_plot(farm_plot: Node) -> Array:
	var snapshot := [farm_plot.scale]
	snapshot.append_array(_capture_invariants(farm_plot))
	return snapshot


func _capture_invariants(farm_plot: Node) -> Array:
	var plot_base := farm_plot.get_node(^"PlotBase") as Sprite2D
	var crop_shadow := farm_plot.get_node(^"CropShadow") as Sprite2D
	var crop_color := farm_plot.get_node(^"CropColor") as Sprite2D
	var hit_area := farm_plot.get_node(^"PlotBase/HitArea") as Area2D
	var hit_shape := farm_plot.get_node(^"PlotBase/HitArea/CollisionShape2D") as CollisionShape2D
	var audio := farm_plot.get_node(^"PlotBase/ActivationAudio") as AudioStreamPlayer
	return [
		farm_plot.position, farm_plot.rotation,
		farm_plot.get_lifecycle_state(), farm_plot.get_visual_state(),
		farm_plot.get_current_crop_id(), farm_plot.get_last_harvested_crop_id(),
		farm_plot.get_started_at_utc(), farm_plot.get_ready_at_utc(),
		plot_base.get_instance_id(), crop_shadow.get_instance_id(), crop_color.get_instance_id(),
		hit_area.get_instance_id(), hit_shape.get_instance_id(), audio.get_instance_id(),
		plot_base.get_parent().get_instance_id(), crop_shadow.get_parent().get_instance_id(), crop_color.get_parent().get_instance_id(),
		hit_area.get_parent().get_instance_id(), hit_shape.get_parent().get_instance_id(), audio.get_parent().get_instance_id(),
		plot_base.position, crop_shadow.position, crop_color.position, hit_area.position, hit_shape.position,
		plot_base.scale, crop_shadow.scale, crop_color.scale, hit_area.scale, hit_shape.scale,
		plot_base.rotation, crop_shadow.rotation, crop_color.rotation, hit_area.rotation, hit_shape.rotation,
		plot_base.z_index, crop_shadow.z_index, crop_color.z_index, hit_area.z_index,
		plot_base.visible, crop_shadow.visible, crop_color.visible, hit_area.visible,
		_texture_path(plot_base), _texture_path(crop_shadow), _texture_path(crop_color),
	]


func _emit_picker_event(farm_plot: Node, event: InputEvent) -> void:
	var hit_area := farm_plot.get_node(^"PlotBase/HitArea") as Area2D
	hit_area.input_event.emit(farm_plot.get_viewport(), event, 0)


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


func _mouse_button(position: Vector2, button_index: MouseButton, pressed: bool, device := 0) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.position = position
	event.button_index = button_index
	event.pressed = pressed
	event.device = device
	return event


func _mouse_motion(position: Vector2) -> InputEventMouseMotion:
	var event := InputEventMouseMotion.new()
	event.position = position
	return event


func _key_event() -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = KEY_SPACE
	event.pressed = true
	return event


func _texture_path(sprite: Sprite2D) -> String:
	if sprite.texture == null:
		return ""
	return sprite.texture.resource_path


func _on_activated() -> void:
	_activation_count += 1


func _expect(condition: bool, description: String) -> void:
	if not condition:
		_failures.append(description)
