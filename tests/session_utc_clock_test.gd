extends SceneTree

const ClockScript = preload("res://scripts/platform/session_utc_clock.gd")
const ControllerScript = preload("res://scripts/farm/farm_plot_interaction_controller.gd")
const FarmPlotScript = preload("res://scripts/farm/farm_plot.gd")
const FARM_PLOT_SCENE := preload("res://scenes/farm/farm_plot.tscn")
const PRIMARY_CROP_ID := &"sunwheat"
const MAX_TIMESTAMP := 9223372036854775807
const INT64_LIMIT_AS_FLOAT := 9223372036854775808.0


class DeterministicClock:
	extends ClockScript

	var system_values: Array = []
	var monotonic_values: Array = []
	var system_read_count := 0
	var monotonic_read_count := 0
	var _system_index := 0
	var _monotonic_index := 0


	func _read_system_utc() -> Variant:
		system_read_count += 1
		if _system_index >= system_values.size():
			return null
		var value: Variant = system_values[_system_index]
		_system_index += 1
		return value


	func _read_monotonic_msec() -> Variant:
		monotonic_read_count += 1
		if _monotonic_index >= monotonic_values.size():
			return null
		var value: Variant = monotonic_values[_monotonic_index]
		_monotonic_index += 1
		return value


var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	_verify_prestart_retry_and_boundaries()
	_verify_call_frequency_independence()
	_verify_invalid_start_ranges()
	_verify_overflow_protection()
	_verify_controller_and_farm_plot_compatibility()
	call_deferred("_finish_test")


func _finish_test() -> void:
	if not _failures.is_empty():
		for failure in _failures:
			printerr("TEST FAILURE: %s" % failure)
		quit(1)
		return
	print("SESSION_UTC_CLOCK_TEST_PASS")
	quit()


func _verify_prestart_retry_and_boundaries() -> void:
	var clock := DeterministicClock.new()
	clock.system_values = [-1.0, 1000.875, 1000.875]
	clock.monotonic_values = [-1, 5000]
	_expect(not clock.is_started(), "new clock should report unstarted")
	_expect(clock.now_utc() == -1, "pre-start now_utc should return -1")
	_expect(clock.system_read_count == 0 and clock.monotonic_read_count == 0, "pre-start now_utc should perform no raw reads")

	_expect(not clock.start(), "negative wall-clock baseline should fail start")
	_expect(not clock.is_started(), "failed wall-clock start should remain unstarted")
	_expect(clock.system_read_count == 1 and clock.monotonic_read_count == 0, "invalid wall time should not sample monotonic baseline")
	_expect(not clock.start(), "negative monotonic baseline should fail start")
	_expect(not clock.is_started(), "failed monotonic start should remain unstarted")
	_expect(clock.system_read_count == 2 and clock.monotonic_read_count == 1, "failed monotonic attempt should read each raw source exactly once")
	_expect(clock.start(), "valid retry should start clock")
	_expect(clock.is_started(), "successful retry should report started")
	_expect(clock.system_read_count == 3 and clock.monotonic_read_count == 2, "successful attempt should sample each baseline exactly once")
	var system_reads_after_start := clock.system_read_count
	var monotonic_reads_after_start := clock.monotonic_read_count
	_expect(not clock.start(), "second start after success should fail")
	_expect(clock.system_read_count == system_reads_after_start and clock.monotonic_read_count == monotonic_reads_after_start, "second start should not resample either baseline")
	_expect(Callable(clock, "now_utc").is_valid(), "started clock now_utc callable should be valid")

	clock.monotonic_values.append_array([5000, 5999, 6000, 6001])
	var returned_values: Array[int] = []
	returned_values.append(clock.now_utc())
	returned_values.append(clock.now_utc())
	returned_values.append(clock.now_utc())
	returned_values.append(clock.now_utc())
	_expect(returned_values == [1000, 1000, 1001, 1001], "clock should floor wall baseline and advance only at exact second boundaries")
	_expect(clock.system_read_count == system_reads_after_start, "now_utc should never resample system UTC")

	for _call_index in 100:
		clock.monotonic_values.append(6001)
		returned_values.append(clock.now_utc())
	_expect(returned_values.back() == 1001, "repeated sub-second calls should not accumulate drift")
	clock.system_values.append(999999999.0)
	clock.monotonic_values.append(8500)
	returned_values.append(clock.now_utc())
	_expect(returned_values.back() == 1003, "multiple-second jump should derive from total baseline elapsed time")
	_expect(clock.system_read_count == system_reads_after_start, "post-start wall-clock change should be ignored")

	clock.monotonic_values.append(8499)
	returned_values.append(clock.now_utc())
	_expect(returned_values.back() == 1003, "monotonic regression should clamp to last valid UTC")
	clock.monotonic_values.append(9000)
	returned_values.append(clock.now_utc())
	_expect(returned_values.back() == 1004, "clock should recover after a regressing sample")
	clock.monotonic_values.append("invalid")
	returned_values.append(clock.now_utc())
	_expect(returned_values.back() == 1004, "nonnumeric monotonic sample should clamp")
	clock.monotonic_values.append(-1)
	returned_values.append(clock.now_utc())
	_expect(returned_values.back() == 1004, "negative monotonic sample should clamp")
	clock.monotonic_values.append(4000)
	returned_values.append(clock.now_utc())
	_expect(returned_values.back() == 1004, "monotonic sample below baseline should clamp")
	clock.monotonic_values.append(8999)
	returned_values.append(clock.now_utc())
	_expect(returned_values.back() == 1004, "sample below prior observation should clamp")
	clock.monotonic_values.append(10000)
	returned_values.append(clock.now_utc())
	_expect(returned_values.back() == 1005, "valid monotonic source should resume from immutable baseline")
	_verify_nondecreasing(returned_values, "boundary and regression trace")


func _verify_call_frequency_independence() -> void:
	var dense_clock := DeterministicClock.new()
	dense_clock.system_values = [3000.9]
	dense_clock.monotonic_values = [0]
	for elapsed_msec in range(1, 5001):
		dense_clock.monotonic_values.append(elapsed_msec)
	_expect(dense_clock.start(), "dense-call clock should start")
	var dense_value := -1
	for _call_index in 5000:
		dense_value = dense_clock.now_utc()

	var sparse_clock := DeterministicClock.new()
	sparse_clock.system_values = [3000.9]
	sparse_clock.monotonic_values = [0, 5000]
	_expect(sparse_clock.start(), "sparse-call clock should start")
	var sparse_value := sparse_clock.now_utc()
	_expect(dense_value == 3005 and sparse_value == 3005, "dense and sparse calls should produce the same five-second result")
	_expect(dense_clock.system_read_count == 1 and sparse_clock.system_read_count == 1, "call frequency should never add wall-clock reads")


func _verify_invalid_start_ranges() -> void:
	var nonfinite_clock := DeterministicClock.new()
	nonfinite_clock.system_values = [INF]
	nonfinite_clock.monotonic_values = [0]
	_expect(not nonfinite_clock.start(), "nonfinite wall baseline should fail")
	_expect(nonfinite_clock.monotonic_read_count == 0, "nonfinite wall baseline should not read monotonic source")

	var overflow_range_clock := DeterministicClock.new()
	overflow_range_clock.system_values = [INT64_LIMIT_AS_FLOAT]
	overflow_range_clock.monotonic_values = [0]
	_expect(not overflow_range_clock.start(), "out-of-range wall baseline should fail")
	_expect(not overflow_range_clock.is_started(), "out-of-range wall baseline should leave clock unstarted")

	var invalid_monotonic_clock := DeterministicClock.new()
	invalid_monotonic_clock.system_values = [100.0]
	invalid_monotonic_clock.monotonic_values = [1.5]
	_expect(not invalid_monotonic_clock.start(), "noninteger monotonic baseline should fail")
	_expect(not invalid_monotonic_clock.is_started(), "invalid monotonic baseline should leave clock unstarted")


func _verify_overflow_protection() -> void:
	var clock := DeterministicClock.new()
	clock.system_values = [MAX_TIMESTAMP - 1]
	clock.monotonic_values = [0, 1000, 2000, 1500, 3000]
	_expect(clock.start(), "near-limit clock should start")
	var values: Array[int] = []
	values.append(clock.now_utc())
	values.append(clock.now_utc())
	values.append(clock.now_utc())
	values.append(clock.now_utc())
	_expect(values == [MAX_TIMESTAMP, MAX_TIMESTAMP, MAX_TIMESTAMP, MAX_TIMESTAMP], "overflow should clamp without wrapping and preserve recoverable state")
	_verify_nondecreasing(values, "overflow trace")


func _verify_controller_and_farm_plot_compatibility() -> void:
	var balance := root.get_node_or_null(^"Balance")
	_expect(balance != null, "real Balance autoload should be present")
	if balance == null:
		return
	var crop_row: Dictionary = balance.call("get_crop", String(PRIMARY_CROP_ID))
	_expect(not crop_row.is_empty() and crop_row.has("growth_sec_eff"), "Balance should provide Sunwheat growth duration")
	if crop_row.is_empty() or not crop_row.has("growth_sec_eff"):
		return
	var growth_seconds := int(ceil(float(crop_row["growth_sec_eff"])))

	var clock := DeterministicClock.new()
	var baseline_utc := 10000
	var baseline_monotonic := 100000
	clock.system_values = [float(baseline_utc) + 0.75, 0.0]
	clock.monotonic_values = [
		baseline_monotonic,
		baseline_monotonic,
		baseline_monotonic + growth_seconds * 1000 - 1,
		baseline_monotonic + growth_seconds * 1000,
		baseline_monotonic + growth_seconds * 1000,
		baseline_monotonic + growth_seconds * 1000 + 5000,
	]
	_expect(clock.start(), "controller integration clock should start")
	var now_callable := Callable(clock, "now_utc")
	_expect(now_callable.is_valid(), "SessionUtcClock now_utc should be a valid controller callable")

	var controller := ControllerScript.new()
	root.add_child(controller)
	_expect(controller.configure(now_callable, PRIMARY_CROP_ID), "controller should accept started SessionUtcClock callable")
	controller.set_process(false)
	var farm_plot := FARM_PLOT_SCENE.instantiate()
	root.add_child(farm_plot)
	_expect(controller.register_plot(farm_plot), "controller should register real FarmPlot")
	farm_plot.emit_signal(&"activated")
	_expect(farm_plot.get_lifecycle_state() == FarmPlotScript.VisualState.GROWING, "clock-backed activation should plant into GROWING")
	_expect(farm_plot.get_started_at_utc() == baseline_utc, "clock-backed planting should use floored baseline UTC")
	_expect(farm_plot.get_ready_at_utc() == baseline_utc + growth_seconds, "FarmPlot deadline should use CSV duration")

	controller._process(0.0)
	_expect(farm_plot.get_lifecycle_state() == FarmPlotScript.VisualState.GROWING, "clock-backed process should remain GROWING one second before deadline")
	controller._process(0.0)
	_expect(farm_plot.get_lifecycle_state() == FarmPlotScript.VisualState.READY, "clock-backed process should reach READY at exact CSV deadline")
	_expect(clock.system_read_count == 1, "controller updates should never resample clock wall time")

	farm_plot.emit_signal(&"activated")
	_expect(farm_plot.get_lifecycle_state() == FarmPlotScript.VisualState.EMPTY, "clock-backed READY activation should harvest to EMPTY")
	controller._process(0.0)
	_expect(farm_plot.get_lifecycle_state() == FarmPlotScript.VisualState.EMPTY, "clock-backed process should not auto-replant")
	_expect(farm_plot.get_current_crop_id() == StringName() and farm_plot.get_last_harvested_crop_id() == PRIMARY_CROP_ID, "harvested crop should remain remembered without automatic planting")
	_expect(clock.system_read_count == 1, "simulated post-start wall change should remain unread")

	controller.set_process(false)
	controller.free()
	farm_plot.free()


func _verify_nondecreasing(values: Array[int], description: String) -> void:
	for index in range(1, values.size()):
		_expect(values[index] >= values[index - 1], "%s should never move backward at index %d" % [description, index])


func _expect(condition: bool, description: String) -> void:
	if not condition:
		_failures.append(description)
