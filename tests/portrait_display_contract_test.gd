extends SceneTree

const EXPECTED_SETTINGS := {
	"display/window/size/viewport_width": 540,
	"display/window/size/viewport_height": 960,
	"display/window/size/window_width_override": 540,
	"display/window/size/window_height_override": 960,
	"display/window/stretch/mode": "canvas_items",
	"display/window/stretch/aspect": "expand",
	"display/window/handheld/orientation": 1,
}

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	for setting_path in EXPECTED_SETTINGS:
		var expected_value: Variant = EXPECTED_SETTINGS[setting_path]
		var actual_value: Variant = ProjectSettings.get_setting(setting_path)
		_expect(typeof(actual_value) == typeof(expected_value), "%s should have type %s, got %s" % [setting_path, type_string(typeof(expected_value)), type_string(typeof(actual_value))])
		_expect(actual_value == expected_value, "%s should be %s, got %s" % [setting_path, expected_value, actual_value])

	var viewport_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
	var viewport_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")
	var override_width: int = ProjectSettings.get_setting("display/window/size/window_width_override")
	var override_height: int = ProjectSettings.get_setting("display/window/size/window_height_override")
	_expect(viewport_width < viewport_height, "logical viewport dimensions should remain portrait, not width/height reversed")
	_expect(override_width < override_height, "window override dimensions should remain portrait, not width/height reversed")
	_expect(root.content_scale_size == Vector2i(540, 960), "root viewport should report a 540x960 logical content size at startup, got %s" % root.content_scale_size)
	_expect(root.content_scale_size.x < root.content_scale_size.y, "root viewport content size should remain portrait, not width/height reversed")

	if _failures.is_empty():
		print("PASS: portrait display contract")
		quit()
		return
	for failure in _failures:
		printerr("TEST FAILURE: %s" % failure)
	quit(1)


func _expect(condition: bool, description: String) -> void:
	if not condition:
		_failures.append(description)
