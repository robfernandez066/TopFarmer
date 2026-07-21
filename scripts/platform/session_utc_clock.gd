class_name SessionUtcClock
extends RefCounted

const MSEC_PER_SECOND := 1000
const MAX_TIMESTAMP := 9223372036854775807
const INT64_LIMIT_AS_FLOAT := 9223372036854775808.0

var _started := false
var _baseline_utc := -1
var _baseline_monotonic_msec := -1
var _last_observed_monotonic_msec := -1
var _last_returned_utc := -1


func start() -> bool:
	if _started:
		_print_diagnostic("start called after successful initialization")
		return false

	var raw_system_utc: Variant = _read_system_utc()
	var utc_result := _validated_system_utc(raw_system_utc)
	if not utc_result["ok"]:
		return false
	var raw_monotonic_msec: Variant = _read_monotonic_msec()
	var monotonic_result := _validated_monotonic_msec(raw_monotonic_msec)
	if not monotonic_result["ok"]:
		return false

	_baseline_utc = utc_result["value"]
	_baseline_monotonic_msec = monotonic_result["value"]
	_last_observed_monotonic_msec = _baseline_monotonic_msec
	_last_returned_utc = _baseline_utc
	_started = true
	return true


func now_utc() -> int:
	if not _started:
		_print_diagnostic("now_utc called before successful start")
		return -1

	var raw_monotonic_msec: Variant = _read_monotonic_msec()
	if typeof(raw_monotonic_msec) != TYPE_INT:
		_print_diagnostic("monotonic source returned a noninteger value")
		return _last_returned_utc
	var current_monotonic_msec := int(raw_monotonic_msec)
	if current_monotonic_msec < 0:
		_print_diagnostic("monotonic source returned a negative value")
		return _last_returned_utc
	if current_monotonic_msec < _baseline_monotonic_msec:
		_print_diagnostic("monotonic source moved below the session baseline")
		return _last_returned_utc
	if current_monotonic_msec < _last_observed_monotonic_msec:
		_print_diagnostic("monotonic source regressed")
		return _last_returned_utc

	var elapsed_msec := current_monotonic_msec - _baseline_monotonic_msec
	@warning_ignore("integer_division")
	var elapsed_seconds := elapsed_msec / MSEC_PER_SECOND
	if elapsed_seconds > MAX_TIMESTAMP - _baseline_utc:
		_print_diagnostic("UTC timestamp addition would overflow")
		return _last_returned_utc

	var calculated_utc := _baseline_utc + elapsed_seconds
	_last_observed_monotonic_msec = current_monotonic_msec
	_last_returned_utc = calculated_utc
	return calculated_utc


func is_started() -> bool:
	return _started


func _read_system_utc() -> Variant:
	return Time.get_unix_time_from_system()


func _read_monotonic_msec() -> Variant:
	return Time.get_ticks_msec()


func _validated_system_utc(raw_system_utc: Variant) -> Dictionary:
	match typeof(raw_system_utc):
		TYPE_INT:
			var integer_utc := int(raw_system_utc)
			if integer_utc < 0:
				_print_diagnostic("system UTC source returned a negative value")
				return {"ok": false, "value": -1}
			return {"ok": true, "value": integer_utc}
		TYPE_FLOAT:
			var floating_utc := float(raw_system_utc)
			if not is_finite(floating_utc):
				_print_diagnostic("system UTC source returned a nonfinite value")
				return {"ok": false, "value": -1}
			if floating_utc < 0.0:
				_print_diagnostic("system UTC source returned a negative value")
				return {"ok": false, "value": -1}
			if floating_utc >= INT64_LIMIT_AS_FLOAT:
				_print_diagnostic("system UTC source exceeds the signed timestamp range")
				return {"ok": false, "value": -1}
			return {"ok": true, "value": int(floor(floating_utc))}
		_:
			_print_diagnostic("system UTC source returned a nonnumeric value")
			return {"ok": false, "value": -1}


func _validated_monotonic_msec(raw_monotonic_msec: Variant) -> Dictionary:
	if typeof(raw_monotonic_msec) != TYPE_INT:
		_print_diagnostic("monotonic baseline source returned a noninteger value")
		return {"ok": false, "value": -1}
	var monotonic_msec := int(raw_monotonic_msec)
	if monotonic_msec < 0:
		_print_diagnostic("monotonic baseline source returned a negative value")
		return {"ok": false, "value": -1}
	return {"ok": true, "value": monotonic_msec}


func _print_diagnostic(message: String) -> void:
	print("SESSION_UTC_CLOCK_DIAGNOSTIC: %s" % message)
