extends SceneTree

const FarmPlotScript = preload("res://scripts/farm/farm_plot.gd")
const FARM_PLOT_SCENE := preload("res://scenes/farm/farm_plot.tscn")
const PLOT_BASE_PATH := "res://assets/sprites/plots/tilled_soil_plot_empty_256.png"
const GROWING_SHADOW_PATH := "res://assets/sprites/crops/sunwheat_shadow_growing_256.png"
const GROWING_COLOR_PATH := "res://assets/sprites/crops/sunwheat_crop_growing_256.png"
const READY_SHADOW_PATH := "res://assets/sprites/crops/sunwheat_shadow_ready_placeholder_256.png"
const READY_COLOR_PATH := "res://assets/sprites/crops/sunwheat_crop_ready_placeholder_256.png"
const BASE_POSITION := Vector2(-128.0, -232.5)
const EMPTY_CROP_POSITION := Vector2(-128.0, -232.5)
const GROWING_CROP_POSITION := Vector2(-127.0, -232.5)
const READY_CROP_POSITION := Vector2(-128.0, -232.5)
const PRIMARY_CROP_ID := &"sunwheat"
const OTHER_CROP_ID := &"duskcorn"
const UNKNOWN_CROP_ID := &"unknown_crop"

var _failures: Array[String] = []
var _visual_node_ids: Array[int] = []
var _visual_parent_ids: Array[int] = []


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var farm_plot := FARM_PLOT_SCENE.instantiate()
	root.add_child(farm_plot)
	_record_visual_identity(farm_plot)
	_verify_initial_and_rejections(farm_plot)
	_verify_primary_crop_cycles(farm_plot)
	_verify_other_crop(farm_plot)
	farm_plot.free()

	if not _failures.is_empty():
		for failure in _failures:
			printerr("TEST FAILURE: %s" % failure)
		quit(1)
		return
	print("FARM_PLOT_CROP_LIFECYCLE_TEST_PASS")
	quit()


func _verify_initial_and_rejections(farm_plot: Node) -> void:
	_verify_lifecycle(farm_plot, FarmPlotScript.VisualState.EMPTY, StringName(), StringName(), -1, -1, "initial EMPTY")
	_verify_visual(farm_plot, FarmPlotScript.VisualState.EMPTY, "initial EMPTY")
	var initial_snapshot := _capture_plot(farm_plot)

	_expect(not farm_plot.plant_crop(StringName(), 0), "empty crop ID should be rejected")
	_expect(_capture_plot(farm_plot) == initial_snapshot, "empty crop rejection should not mutate the plot")
	_expect(not farm_plot.plant_crop(UNKNOWN_CROP_ID, 0), "unknown crop ID should be rejected")
	_expect(_capture_plot(farm_plot) == initial_snapshot, "unknown crop rejection should not mutate the plot")
	_expect(not farm_plot.plant_crop(PRIMARY_CROP_ID, -1), "negative planting timestamp should be rejected")
	_expect(_capture_plot(farm_plot) == initial_snapshot, "negative timestamp rejection should not mutate the plot")
	_expect(farm_plot.harvest_crop() == StringName(), "EMPTY harvest should return an empty crop ID")
	_expect(_capture_plot(farm_plot) == initial_snapshot, "EMPTY harvest should not mutate the plot")
	_expect(not farm_plot.replant_last_crop(0), "replant should fail before the first harvest")
	_expect(_capture_plot(farm_plot) == initial_snapshot, "pre-harvest replant should not mutate the plot")
	farm_plot.update_growth(0)
	_expect(_capture_plot(farm_plot) == initial_snapshot, "EMPTY growth update should not mutate the plot")


func _verify_primary_crop_cycles(farm_plot: Node) -> void:
	var growth_seconds := _growth_seconds_from_balance(PRIMARY_CROP_ID)
	if growth_seconds <= 0:
		return

	var first_start := 1000
	_expect(farm_plot.plant_crop(PRIMARY_CROP_ID, first_start), "valid primary crop planting should succeed")
	_verify_lifecycle(farm_plot, FarmPlotScript.VisualState.GROWING, PRIMARY_CROP_ID, StringName(), first_start, first_start + growth_seconds, "first planting")
	_verify_visual(farm_plot, FarmPlotScript.VisualState.GROWING, "first planting")

	var occupied_snapshot := _capture_plot(farm_plot)
	_expect(not farm_plot.plant_crop(OTHER_CROP_ID, first_start), "planting while GROWING should fail")
	_expect(_capture_plot(farm_plot) == occupied_snapshot, "GROWING occupancy rejection should not mutate the plot")
	_expect(not farm_plot.replant_last_crop(first_start), "replant while GROWING should fail")
	_expect(_capture_plot(farm_plot) == occupied_snapshot, "GROWING replant rejection should not mutate the plot")
	_expect(farm_plot.harvest_crop() == StringName(), "premature harvest should return an empty crop ID")
	_expect(_capture_plot(farm_plot) == occupied_snapshot, "premature harvest should not mutate the plot")

	farm_plot.update_growth(first_start - 1)
	_expect(_capture_plot(farm_plot) == occupied_snapshot, "backward supplied time should not mutate the plot")
	farm_plot.update_growth(first_start + growth_seconds - 1)
	_verify_lifecycle(farm_plot, FarmPlotScript.VisualState.GROWING, PRIMARY_CROP_ID, StringName(), first_start, first_start + growth_seconds, "one second before first deadline")
	_verify_visual(farm_plot, FarmPlotScript.VisualState.GROWING, "one second before first deadline")
	farm_plot.update_growth(first_start + growth_seconds)
	_verify_lifecycle(farm_plot, FarmPlotScript.VisualState.READY, PRIMARY_CROP_ID, StringName(), first_start, first_start + growth_seconds, "first exact deadline")
	_verify_visual(farm_plot, FarmPlotScript.VisualState.READY, "first exact deadline")

	var ready_snapshot := _capture_plot(farm_plot)
	_expect(not farm_plot.plant_crop(OTHER_CROP_ID, first_start), "planting while READY should fail")
	_expect(_capture_plot(farm_plot) == ready_snapshot, "READY occupancy rejection should not mutate the plot")
	farm_plot.update_growth(first_start)
	_expect(_capture_plot(farm_plot) == ready_snapshot, "READY should ignore backward growth updates")
	_expect(farm_plot.harvest_crop() == PRIMARY_CROP_ID, "first harvest should return the primary crop ID")
	_verify_lifecycle(farm_plot, FarmPlotScript.VisualState.EMPTY, StringName(), PRIMARY_CROP_ID, -1, -1, "after first harvest")
	_verify_visual(farm_plot, FarmPlotScript.VisualState.EMPTY, "after first harvest")

	var harvested_snapshot := _capture_plot(farm_plot)
	_expect(not farm_plot.replant_last_crop(-1), "replant with a negative timestamp should fail")
	_expect(_capture_plot(farm_plot) == harvested_snapshot, "negative replant timestamp should not mutate the plot")
	farm_plot.update_growth(first_start + growth_seconds * 2)
	_expect(_capture_plot(farm_plot) == harvested_snapshot, "EMPTY should not auto-replant during growth updates")
	var second_start := first_start + growth_seconds * 3
	_expect(farm_plot.replant_last_crop(second_start), "first explicit replant action should succeed")
	_verify_lifecycle(farm_plot, FarmPlotScript.VisualState.GROWING, PRIMARY_CROP_ID, PRIMARY_CROP_ID, second_start, second_start + growth_seconds, "first explicit replant")
	_verify_visual(farm_plot, FarmPlotScript.VisualState.GROWING, "first explicit replant")

	farm_plot.update_growth(second_start + growth_seconds - 1)
	_verify_lifecycle(farm_plot, FarmPlotScript.VisualState.GROWING, PRIMARY_CROP_ID, PRIMARY_CROP_ID, second_start, second_start + growth_seconds, "one second before second deadline")
	farm_plot.update_growth(second_start + growth_seconds)
	_verify_visual(farm_plot, FarmPlotScript.VisualState.READY, "second exact deadline")
	_expect(farm_plot.harvest_crop() == PRIMARY_CROP_ID, "second harvest should return the primary crop ID")
	_verify_lifecycle(farm_plot, FarmPlotScript.VisualState.EMPTY, StringName(), PRIMARY_CROP_ID, -1, -1, "after second harvest")
	_verify_visual(farm_plot, FarmPlotScript.VisualState.EMPTY, "after second harvest")

	var third_start := second_start + growth_seconds * 3
	_expect(farm_plot.replant_last_crop(third_start), "second explicit replant action should succeed")
	_verify_lifecycle(farm_plot, FarmPlotScript.VisualState.GROWING, PRIMARY_CROP_ID, PRIMARY_CROP_ID, third_start, third_start + growth_seconds, "second explicit replant")
	_verify_visual(farm_plot, FarmPlotScript.VisualState.GROWING, "second explicit replant")
	farm_plot.update_growth(third_start + growth_seconds)
	_expect(farm_plot.harvest_crop() == PRIMARY_CROP_ID, "third harvest should return the primary crop ID")
	_verify_lifecycle(farm_plot, FarmPlotScript.VisualState.EMPTY, StringName(), PRIMARY_CROP_ID, -1, -1, "after third harvest")
	_verify_visual(farm_plot, FarmPlotScript.VisualState.EMPTY, "after third harvest")


func _verify_other_crop(farm_plot: Node) -> void:
	var growth_seconds := _growth_seconds_from_balance(OTHER_CROP_ID)
	if growth_seconds <= 0:
		return
	var start_time := 50000
	_expect(farm_plot.plant_crop(OTHER_CROP_ID, start_time), "another valid Balance crop should plant through the generic API")
	_verify_lifecycle(farm_plot, FarmPlotScript.VisualState.GROWING, OTHER_CROP_ID, PRIMARY_CROP_ID, start_time, start_time + growth_seconds, "other crop planting")
	_verify_visual(farm_plot, FarmPlotScript.VisualState.GROWING, "other crop planting")
	farm_plot.update_growth(start_time + growth_seconds)
	_verify_lifecycle(farm_plot, FarmPlotScript.VisualState.READY, OTHER_CROP_ID, PRIMARY_CROP_ID, start_time, start_time + growth_seconds, "other crop ready")
	_verify_visual(farm_plot, FarmPlotScript.VisualState.READY, "other crop ready")
	_expect(farm_plot.harvest_crop() == OTHER_CROP_ID, "other crop harvest should return its own ID")
	_verify_lifecycle(farm_plot, FarmPlotScript.VisualState.EMPTY, StringName(), OTHER_CROP_ID, -1, -1, "after other crop harvest")
	_verify_visual(farm_plot, FarmPlotScript.VisualState.EMPTY, "after other crop harvest")


func _growth_seconds_from_balance(crop_id: StringName) -> int:
	var balance := root.get_node_or_null(^"Balance")
	_expect(balance != null, "real Balance autoload should be present")
	if balance == null:
		return -1
	var crop_row: Dictionary = balance.call("get_crop", String(crop_id))
	_expect(not crop_row.is_empty(), "Balance should contain crop '%s'" % crop_id)
	_expect(crop_row.has("growth_sec_eff"), "crop '%s' should have growth_sec_eff" % crop_id)
	if crop_row.is_empty() or not crop_row.has("growth_sec_eff"):
		return -1
	var growth_seconds := int(ceil(float(crop_row["growth_sec_eff"])))
	_expect(growth_seconds > 0, "crop '%s' should have a positive CSV growth duration" % crop_id)
	return growth_seconds


func _record_visual_identity(farm_plot: Node) -> void:
	var nodes := [farm_plot.get_node(^"PlotBase"), farm_plot.get_node(^"CropShadow"), farm_plot.get_node(^"CropColor")]
	for node in nodes:
		_visual_node_ids.append(node.get_instance_id())
		_visual_parent_ids.append(node.get_parent().get_instance_id())


func _verify_lifecycle(farm_plot: Node, state: int, current_crop_id: StringName, last_crop_id: StringName, started_at_utc: int, ready_at_utc: int, description: String) -> void:
	_expect(farm_plot.get_lifecycle_state() == state, "%s lifecycle state should match" % description)
	_expect(farm_plot.get_current_crop_id() == current_crop_id, "%s current crop ID should match" % description)
	_expect(farm_plot.get_last_harvested_crop_id() == last_crop_id, "%s last harvested crop ID should match" % description)
	_expect(farm_plot.get_started_at_utc() == started_at_utc, "%s started timestamp should match" % description)
	_expect(farm_plot.get_ready_at_utc() == ready_at_utc, "%s ready timestamp should use the CSV duration" % description)


func _verify_visual(farm_plot: Node, state: int, description: String) -> void:
	var plot_base := farm_plot.get_node(^"PlotBase") as Sprite2D
	var crop_shadow := farm_plot.get_node(^"CropShadow") as Sprite2D
	var crop_color := farm_plot.get_node(^"CropColor") as Sprite2D
	var expected_position := EMPTY_CROP_POSITION
	var expected_shadow_path := ""
	var expected_color_path := ""
	var expected_visibility := false
	match state:
		FarmPlotScript.VisualState.GROWING:
			expected_position = GROWING_CROP_POSITION
			expected_shadow_path = GROWING_SHADOW_PATH
			expected_color_path = GROWING_COLOR_PATH
			expected_visibility = true
		FarmPlotScript.VisualState.READY:
			expected_position = READY_CROP_POSITION
			expected_shadow_path = READY_SHADOW_PATH
			expected_color_path = READY_COLOR_PATH
			expected_visibility = true

	_expect(farm_plot.get_visual_state() == state, "%s visual state should follow lifecycle" % description)
	_expect(plot_base.texture != null and plot_base.texture.resource_path == PLOT_BASE_PATH, "%s plot base texture should remain exact" % description)
	_expect(plot_base.position == BASE_POSITION and plot_base.scale == Vector2.ONE and plot_base.rotation == 0.0 and plot_base.skew == 0.0, "%s plot base transform should remain exact" % description)
	_expect(crop_shadow.position == expected_position and crop_color.position == expected_position, "%s crop layers should share the exact state position" % description)
	_expect(crop_shadow.scale == Vector2.ONE and crop_color.scale == Vector2.ONE, "%s crop scales should remain exact" % description)
	_expect(crop_shadow.rotation == 0.0 and crop_color.rotation == 0.0 and crop_shadow.skew == 0.0 and crop_color.skew == 0.0, "%s crop rotation and skew should remain exact" % description)
	_expect(crop_shadow.visible == expected_visibility and crop_color.visible == expected_visibility, "%s crop visibility should match lifecycle" % description)
	_expect(plot_base.z_index == 0 and crop_shadow.z_index == 1 and crop_color.z_index == 2, "%s shadow should remain below color with fixed z-order" % description)
	if expected_visibility:
		_expect(crop_shadow.texture != null and crop_shadow.texture.resource_path == expected_shadow_path, "%s shadow path should remain exact" % description)
		_expect(crop_color.texture != null and crop_color.texture.resource_path == expected_color_path, "%s color path should remain exact" % description)
	else:
		_expect(crop_shadow.texture == null and crop_color.texture == null, "%s EMPTY crop textures should be cleared" % description)
	var nodes := [plot_base, crop_shadow, crop_color]
	for index in nodes.size():
		_expect(nodes[index].get_instance_id() == _visual_node_ids[index], "%s visual node identity should not drift" % description)
		_expect(nodes[index].get_parent().get_instance_id() == _visual_parent_ids[index], "%s visual node parenting should not drift" % description)


func _capture_plot(farm_plot: Node) -> Array:
	var plot_base := farm_plot.get_node(^"PlotBase") as Sprite2D
	var crop_shadow := farm_plot.get_node(^"CropShadow") as Sprite2D
	var crop_color := farm_plot.get_node(^"CropColor") as Sprite2D
	return [
		farm_plot.get_current_crop_id(), farm_plot.get_last_harvested_crop_id(),
		farm_plot.get_started_at_utc(), farm_plot.get_ready_at_utc(),
		farm_plot.get_lifecycle_state(), farm_plot.get_visual_state(),
		plot_base.get_instance_id(), crop_shadow.get_instance_id(), crop_color.get_instance_id(),
		plot_base.get_parent().get_instance_id(), crop_shadow.get_parent().get_instance_id(), crop_color.get_parent().get_instance_id(),
		plot_base.texture.resource_path, _texture_path(crop_shadow), _texture_path(crop_color),
		plot_base.position, crop_shadow.position, crop_color.position,
		plot_base.scale, crop_shadow.scale, crop_color.scale,
		plot_base.rotation, crop_shadow.rotation, crop_color.rotation,
		plot_base.skew, crop_shadow.skew, crop_color.skew,
		plot_base.z_index, crop_shadow.z_index, crop_color.z_index,
		plot_base.visible, crop_shadow.visible, crop_color.visible,
	]


func _texture_path(sprite: Sprite2D) -> String:
	if sprite.texture == null:
		return ""
	return sprite.texture.resource_path


func _expect(condition: bool, description: String) -> void:
	if not condition:
		_failures.append(description)
