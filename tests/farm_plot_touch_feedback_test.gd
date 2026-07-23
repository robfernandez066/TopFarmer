extends SceneTree

const FarmPlotScript = preload("res://scripts/farm/farm_plot.gd")
const FARM_PLOT_SCENE := preload("res://scenes/farm/farm_plot.tscn")
const AUDIO_PATH := "res://assets/audio/sfx/ui_tap_soft.wav"
const AUDIO_SHA256 := "359C8C98ECD48368F45B84D3A9B9D7E68CF3AC2FEFCDBF32367B8482DA76C9C7"
const AUDIO_BYTE_SIZE := 16596
const HIT_AREA_SIZE := Vector2(232.0, 216.0)
const HIT_SHAPE_POSITION := Vector2(0.0, -112.0)
const PRESS_SCALE_FACTOR := 0.97
const PULSE_HALF_DURATION := 0.05
const CONFIRMED_TAP_META := &"farm_plot_confirmed_tap"
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
	farm_plot.activated.connect(_on_activated)

	_verify_structure_and_audio(farm_plot)
	await _verify_silent_candidates_and_confirmed_pulse(farm_plot)
	_verify_confirmed_feedback_in_all_states(farm_plot)
	_verify_rejections_and_cancellation(farm_plot)
	_verify_pulse_interruption_and_repetition(farm_plot)
	_verify_tree_exit_restoration()

	var audio := farm_plot.get_node(^"PlotBase/ActivationAudio") as AudioStreamPlayer
	audio.stop()
	audio.stream = null
	farm_plot.queue_free()
	await create_timer(0.25).timeout
	await process_frame

	if not _failures.is_empty():
		for failure in _failures:
			printerr("TEST FAILURE: %s" % failure)
		quit(1)
		return
	print("FARM_PLOT_TOUCH_FEEDBACK_TEST_PASS")
	quit()


func _verify_structure_and_audio(farm_plot: Node) -> void:
	_expect(farm_plot.has_signal(&"activated"), "FarmPlot should declare activated")
	_expect(farm_plot.get_child_count() == 3, "existing three direct visual children should remain exact")
	var hit_areas := farm_plot.find_children("*", "Area2D", true, false)
	_expect(hit_areas.size() == 1, "FarmPlot should contain exactly one Area2D")
	if hit_areas.size() == 1:
		var hit_area := hit_areas[0] as Area2D
		_expect(hit_area.input_pickable, "hit area should be input-pickable")
		_expect(farm_plot.to_local(hit_area.global_position).is_equal_approx(Vector2.ZERO), "hit area should resolve to the ground-contact origin")
		var hit_shape := hit_area.get_node(^"CollisionShape2D") as CollisionShape2D
		_expect(hit_shape.position == HIT_SHAPE_POSITION, "collision shape position should remain exactly (0, -112)")
		var rectangle := hit_shape.shape as RectangleShape2D
		_expect(rectangle != null and rectangle.size == HIT_AREA_SIZE, "hit rectangle should remain exactly (232, 216)")

	var audio_players := farm_plot.find_children("*", "AudioStreamPlayer", true, false)
	_expect(audio_players.size() == 1, "FarmPlot should contain exactly one non-positional AudioStreamPlayer")
	if audio_players.size() != 1:
		return
	var audio := audio_players[0] as AudioStreamPlayer
	_expect(audio.stream != null and audio.stream.resource_path == AUDIO_PATH, "activation audio should use only the approved runtime WAV")
	_expect(not audio.autoplay and audio.volume_db == 0.0 and audio.pitch_scale == 1.0, "activation audio playback settings should remain exact")
	var wav := audio.stream as AudioStreamWAV
	_expect(wav != null and wav.loop_mode == AudioStreamWAV.LOOP_DISABLED, "activation audio should remain non-looping WAV")
	if wav != null:
		_expect(wav.format == AudioStreamWAV.FORMAT_16_BITS and wav.stereo and wav.mix_rate == 44100, "activation audio should remain stereo 16-bit 44.1 kHz")
	var audio_file := FileAccess.open(AUDIO_PATH, FileAccess.READ)
	_expect(audio_file != null and audio_file.get_length() == AUDIO_BYTE_SIZE, "runtime activation WAV should preserve exact byte size")
	_expect(FileAccess.get_sha256(AUDIO_PATH).to_upper() == AUDIO_SHA256, "runtime activation WAV should preserve approved SHA-256")


func _verify_silent_candidates_and_confirmed_pulse(farm_plot: Node) -> void:
	var inside: Vector2 = farm_plot.to_global(HIT_SHAPE_POSITION)
	var base_scale: Vector2 = farm_plot.scale
	var base_position: Vector2 = farm_plot.position
	var base_rotation: float = farm_plot.rotation
	var audio := farm_plot.get_node(^"PlotBase/ActivationAudio") as AudioStreamPlayer
	var before := _activation_count
	audio.stop()
	_emit_picker_event(farm_plot, _touch_event(1, inside, true))
	_expect(farm_plot.scale == base_scale, "touch-down should remain exactly unscaled")
	_expect(not audio.playing, "touch-down should remain silent")
	_expect(_activation_count == before, "touch-down should not activate")
	await create_timer(0.08).timeout
	_expect(farm_plot.scale == base_scale and not audio.playing and _activation_count == before, "held possible tap should remain inert for any duration")

	farm_plot._input(_confirmed_touch(1, inside))
	_expect(_activation_count == before + 1, "confirmed release should activate exactly once immediately")
	_expect(audio.playing, "confirmed release should play exactly the approved click")
	_expect(farm_plot.scale == base_scale, "confirmed pulse should begin at exact normal scale")
	_expect(farm_plot.position == base_position and farm_plot.rotation == base_rotation, "pulse should preserve ground origin and rotation")
	_advance_pulse(farm_plot, PULSE_HALF_DURATION)
	_expect(farm_plot.scale.is_equal_approx(base_scale * PRESS_SCALE_FACTOR), "pulse should reach exact 0.97 scale after 0.05 seconds")
	_expect(farm_plot.position == base_position and farm_plot.rotation == base_rotation, "down pulse should stay anchored at ground contact")
	_advance_pulse(farm_plot, PULSE_HALF_DURATION)
	_expect(farm_plot.scale == base_scale, "pulse should restore exact normal scale after 0.10 seconds")


func _verify_confirmed_feedback_in_all_states(farm_plot: Node) -> void:
	_verify_lifecycle_state(farm_plot, FarmPlotScript.VisualState.EMPTY, "EMPTY before confirmation")
	_perform_confirmed_touch(farm_plot, 2, "EMPTY confirmation")
	_verify_lifecycle_state(farm_plot, FarmPlotScript.VisualState.EMPTY, "EMPTY after confirmation")

	var balance := root.get_node_or_null(^"Balance")
	_expect(balance != null, "real Balance autoload should be present")
	if balance == null:
		return
	var crop_row: Dictionary = balance.call("get_crop", String(PRIMARY_CROP_ID))
	var growth_seconds := int(ceil(float(crop_row.get("growth_sec_eff", 0.0))))
	_expect(growth_seconds > 0, "Balance should provide positive Sunwheat growth_sec_eff")
	var start_time := 1000
	_expect(farm_plot.plant_crop(PRIMARY_CROP_ID, start_time), "test setup should plant Sunwheat")
	_verify_lifecycle_state(farm_plot, FarmPlotScript.VisualState.GROWING, "GROWING before confirmation")
	_perform_confirmed_mouse(farm_plot, "GROWING confirmation")
	_verify_lifecycle_state(farm_plot, FarmPlotScript.VisualState.GROWING, "GROWING after confirmation")

	farm_plot.update_growth(start_time + growth_seconds)
	_verify_lifecycle_state(farm_plot, FarmPlotScript.VisualState.READY, "READY before confirmation")
	_perform_confirmed_touch(farm_plot, 3, "READY confirmation")
	_verify_lifecycle_state(farm_plot, FarmPlotScript.VisualState.READY, "READY after confirmation")


func _verify_rejections_and_cancellation(farm_plot: Node) -> void:
	var inside: Vector2 = farm_plot.to_global(HIT_SHAPE_POSITION)
	var outside: Vector2 = farm_plot.to_global(Vector2(HIT_AREA_SIZE.x, HIT_SHAPE_POSITION.y))
	var base_scale: Vector2 = farm_plot.scale
	var before := _activation_count
	var audio := farm_plot.get_node(^"PlotBase/ActivationAudio") as AudioStreamPlayer

	audio.stop()
	_emit_picker_event(farm_plot, _touch_event(4, inside, true))
	farm_plot._input(_touch_event(4, inside, false))
	_expect(_activation_count == before and not audio.playing and farm_plot.scale == base_scale, "unmarked raw release should never bypass camera classification")
	farm_plot.call("_discard_gesture")

	_emit_picker_event(farm_plot, _touch_event(5, inside, true))
	farm_plot._input(_confirmed_touch(6, inside))
	_expect(_activation_count == before, "different finger confirmation should not activate")
	farm_plot.call("_discard_gesture")

	_emit_picker_event(farm_plot, _touch_event(7, inside, true))
	farm_plot._input(_confirmed_touch(7, outside))
	_expect(_activation_count == before and not audio.playing, "release outside original plot should remain silent and inactive")

	_emit_picker_event(farm_plot, _touch_event(8, inside, true))
	farm_plot.call("_discard_gesture")
	farm_plot._input(_confirmed_touch(8, inside))
	_expect(_activation_count == before and farm_plot.scale == base_scale, "camera cancellation should discard pending touch")

	_emit_picker_event(farm_plot, _mouse_button(inside, MOUSE_BUTTON_LEFT, true, InputEvent.DEVICE_ID_EMULATION))
	farm_plot._input(_confirmed_mouse(inside, InputEvent.DEVICE_ID_EMULATION))
	_expect(_activation_count == before and not audio.playing, "emulated mouse should not create feedback or activation")

	_emit_picker_event(farm_plot, _touch_event(9, inside, true))
	farm_plot.hide()
	farm_plot.show()
	farm_plot._input(_confirmed_touch(9, inside))
	_expect(_activation_count == before and farm_plot.scale == base_scale, "visibility loss should discard pending tap")

	_emit_picker_event(farm_plot, _touch_event(10, inside, true))
	farm_plot._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	farm_plot._input(_confirmed_touch(10, inside))
	_expect(_activation_count == before and farm_plot.scale == base_scale, "focus loss should discard pending tap")


func _verify_pulse_interruption_and_repetition(farm_plot: Node) -> void:
	var inside: Vector2 = farm_plot.to_global(HIT_SHAPE_POSITION)
	var base_scale: Vector2 = farm_plot.scale
	var before := _activation_count
	_emit_picker_event(farm_plot, _touch_event(11, inside, true))
	farm_plot._input(_confirmed_touch(11, inside))
	_expect(_activation_count == before + 1, "pulse interruption setup should confirm one action")
	_advance_pulse(farm_plot, 0.025)
	_expect(not farm_plot.scale.is_equal_approx(base_scale), "pulse should be in flight before camera cancellation")
	farm_plot.call("_discard_gesture")
	_expect(farm_plot.scale == base_scale, "new camera gesture cancellation should restore exact scale immediately")
	_expect(_activation_count == before + 1, "pulse cancellation must not undo confirmed activation")

	var expected := _activation_count
	for gesture_index in 10:
		_perform_confirmed_mouse(farm_plot, "repeated confirmation %d" % (gesture_index + 1))
		expected += 1
		_expect(_activation_count == expected, "repeated confirmation %d should activate exactly once" % (gesture_index + 1))
		_expect(farm_plot.scale == base_scale, "repeated confirmation %d should leave no scale drift" % (gesture_index + 1))


func _verify_tree_exit_restoration() -> void:
	var farm_plot := FARM_PLOT_SCENE.instantiate()
	root.add_child(farm_plot)
	farm_plot.scale = Vector2(1.1, 0.9)
	var base_scale: Vector2 = farm_plot.scale
	var inside: Vector2 = farm_plot.to_global(HIT_SHAPE_POSITION)
	var before := _activation_count
	_emit_picker_event(farm_plot, _touch_event(30, inside, true))
	root.remove_child(farm_plot)
	_expect(farm_plot.scale == base_scale and _activation_count == before, "scene exit should discard silently and restore exact scale")
	var audio := farm_plot.get_node(^"PlotBase/ActivationAudio") as AudioStreamPlayer
	audio.stop()
	audio.stream = null
	farm_plot.free()


func _perform_confirmed_touch(farm_plot: Node, touch_id: int, description: String) -> void:
	var inside: Vector2 = farm_plot.to_global(HIT_SHAPE_POSITION)
	var base_scale: Vector2 = farm_plot.scale
	var invariant_snapshot := _capture_invariants(farm_plot)
	var before := _activation_count
	var audio := farm_plot.get_node(^"PlotBase/ActivationAudio") as AudioStreamPlayer
	audio.stop()
	_emit_picker_event(farm_plot, _touch_event(touch_id, inside, true))
	_expect(farm_plot.scale == base_scale and not audio.playing and _activation_count == before, "%s press should stay inert" % description)
	farm_plot._input(_confirmed_touch(touch_id, inside))
	_expect(_activation_count == before + 1 and audio.playing, "%s should click and activate once only after confirmation" % description)
	_advance_pulse(farm_plot, 0.1)
	_expect(farm_plot.scale == base_scale and _capture_invariants(farm_plot) == invariant_snapshot, "%s should restore without lifecycle or node drift" % description)


func _perform_confirmed_mouse(farm_plot: Node, description: String) -> void:
	var inside: Vector2 = farm_plot.to_global(HIT_SHAPE_POSITION)
	var base_scale: Vector2 = farm_plot.scale
	var invariant_snapshot := _capture_invariants(farm_plot)
	var before := _activation_count
	var audio := farm_plot.get_node(^"PlotBase/ActivationAudio") as AudioStreamPlayer
	audio.stop()
	_emit_picker_event(farm_plot, _mouse_button(inside, MOUSE_BUTTON_LEFT, true))
	_expect(farm_plot.scale == base_scale and not audio.playing and _activation_count == before, "%s press should stay inert" % description)
	farm_plot._input(_confirmed_mouse(inside))
	_expect(_activation_count == before + 1 and audio.playing, "%s should click and activate once only after confirmation" % description)
	_advance_pulse(farm_plot, 0.1)
	_expect(farm_plot.scale == base_scale and _capture_invariants(farm_plot) == invariant_snapshot, "%s should restore without lifecycle or node drift" % description)


func _advance_pulse(farm_plot: Node, seconds: float) -> void:
	var tween := farm_plot.get("_pulse_tween") as Tween
	_expect(tween != null, "confirmed feedback should own one active pulse tween")
	if tween != null:
		tween.custom_step(seconds)


func _verify_lifecycle_state(farm_plot: Node, expected_state: int, description: String) -> void:
	_expect(farm_plot.get_lifecycle_state() == expected_state, "%s lifecycle state should remain exact" % description)
	_expect(farm_plot.get_visual_state() == expected_state, "%s visual state should remain exact" % description)


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
		plot_base.position, crop_shadow.position, crop_color.position, hit_area.position, hit_shape.position,
		plot_base.scale, crop_shadow.scale, crop_color.scale, hit_area.scale, hit_shape.scale,
		plot_base.rotation, crop_shadow.rotation, crop_color.rotation, hit_area.rotation, hit_shape.rotation,
		plot_base.z_index, crop_shadow.z_index, crop_color.z_index, hit_area.z_index,
		plot_base.visible, crop_shadow.visible, crop_color.visible, hit_area.visible,
	]


func _emit_picker_event(farm_plot: Node, event: InputEvent) -> void:
	var hit_area := farm_plot.get_node(^"PlotBase/HitArea") as Area2D
	hit_area.input_event.emit(farm_plot.get_viewport(), event, 0)


func _confirmed_touch(index: int, position: Vector2) -> InputEventScreenTouch:
	var event := _touch_event(index, position, false)
	event.set_meta(CONFIRMED_TAP_META, true)
	return event


func _confirmed_mouse(position: Vector2, device := 0) -> InputEventMouseButton:
	var event := _mouse_button(position, MOUSE_BUTTON_LEFT, false, device)
	event.set_meta(CONFIRMED_TAP_META, true)
	return event


func _touch_event(index: int, position: Vector2, pressed: bool, canceled := false) -> InputEventScreenTouch:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = position
	event.pressed = pressed
	event.canceled = canceled
	return event


func _mouse_button(position: Vector2, button_index: MouseButton, pressed: bool, device := 0) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.position = position
	event.button_index = button_index
	event.pressed = pressed
	event.device = device
	return event


func _on_activated() -> void:
	_activation_count += 1


func _expect(condition: bool, description: String) -> void:
	if not condition:
		_failures.append(description)
