extends SceneTree

const FarmPlotScript = preload("res://scripts/farm/farm_plot.gd")
const FARM_PLOT_SCENE := preload("res://scenes/farm/farm_plot.tscn")
const PLOT_BASE_PATH := "res://assets/sprites/plots/tilled_soil_plot_empty_256.png"
const GROWING_SHADOW_PATH := "res://assets/sprites/crops/sunwheat_shadow_growing_256.png"
const GROWING_COLOR_PATH := "res://assets/sprites/crops/sunwheat_crop_growing_256.png"
const READY_SHADOW_PATH := "res://assets/sprites/crops/sunwheat_shadow_ready_256.png"
const READY_COLOR_PATH := "res://assets/sprites/crops/sunwheat_crop_ready_256.png"
const BASE_POSITION := Vector2(-128.0, -232.5)
const EMPTY_CROP_POSITION := Vector2(-128.0, -232.5)
const GROWING_CROP_POSITION := Vector2(-127.0, -232.5)
const READY_CROP_POSITION := Vector2(-140.0, -232.5)
const SOIL_CONTACT_Y := -232.5

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var farm_plot := FARM_PLOT_SCENE.instantiate()
	root.add_child(farm_plot)
	_verify_structure(farm_plot)
	if farm_plot.get_child_count() == 3:
		_verify_states(farm_plot)
	farm_plot.free()

	if _failures.is_empty():
		print("PASS: farm plot visual states")
		quit()
		return
	for failure in _failures:
		printerr("TEST FAILURE: %s" % failure)
	quit(1)


func _verify_structure(farm_plot: Node) -> void:
	_expect(farm_plot is Node2D, "FarmPlot root should be Node2D")
	_expect(farm_plot.name == &"FarmPlot", "root should be named FarmPlot")
	_expect(farm_plot.get_child_count() == 3, "FarmPlot should have exactly three direct children")
	if farm_plot.get_child_count() != 3:
		return

	var expected_names := [&"PlotBase", &"CropShadow", &"CropColor"]
	for index in expected_names.size():
		var child := farm_plot.get_child(index)
		_expect(child is Sprite2D, "%s should be a Sprite2D" % expected_names[index])
		_expect(child.name == expected_names[index], "child %d should be named %s" % [index, expected_names[index]])

	_verify_node_transform(farm_plot as Node2D, Vector2.ZERO, "FarmPlot")
	for child_name in expected_names:
		var sprite := farm_plot.get_node(NodePath(child_name)) as Sprite2D
		_expect(not sprite.centered, "%s should not be centered" % child_name)
		_expect(sprite.material == null, "%s should not have a material" % child_name)
		_expect(sprite.texture_filter == CanvasItem.TEXTURE_FILTER_PARENT_NODE, "%s should inherit texture filtering" % child_name)
	_verify_node_transform(farm_plot.get_node(^"PlotBase") as Sprite2D, BASE_POSITION, "PlotBase")
	_verify_node_transform(farm_plot.get_node(^"CropShadow") as Sprite2D, EMPTY_CROP_POSITION, "CropShadow")
	_verify_node_transform(farm_plot.get_node(^"CropColor") as Sprite2D, EMPTY_CROP_POSITION, "CropColor")
	_expect((farm_plot.get_node(^"PlotBase") as Sprite2D).z_index == 0, "plot base z-order should remain zero")
	_expect((farm_plot.get_node(^"CropShadow") as Sprite2D).z_index == 1, "crop shadow z-order should remain one")
	_expect((farm_plot.get_node(^"CropColor") as Sprite2D).z_index == 2, "crop color z-order should remain two")
	_expect((farm_plot.get_node(^"PlotBase") as Sprite2D).z_index < (farm_plot.get_node(^"CropShadow") as Sprite2D).z_index, "plot base should stack below crop shadow")
	_expect((farm_plot.get_node(^"CropShadow") as Sprite2D).z_index < (farm_plot.get_node(^"CropColor") as Sprite2D).z_index, "crop shadow should stack below crop color")


func _verify_states(farm_plot: Node) -> void:
	var plot_base := farm_plot.get_node(^"PlotBase") as Sprite2D
	var crop_shadow := farm_plot.get_node(^"CropShadow") as Sprite2D
	var crop_color := farm_plot.get_node(^"CropColor") as Sprite2D
	var original_root_position: Vector2 = farm_plot.position
	var original_base_texture: Texture2D = plot_base.texture
	var original_node_ids := [plot_base.get_instance_id(), crop_shadow.get_instance_id(), crop_color.get_instance_id()]
	var original_z_indices := [plot_base.z_index, crop_shadow.z_index, crop_color.z_index]

	_expect(farm_plot.initial_visual_state == FarmPlotScript.VisualState.EMPTY, "initial visual state should default to EMPTY")
	_verify_state(farm_plot, FarmPlotScript.VisualState.EMPTY, false, "", "")
	for cycle in 2:
		_verify_transition(farm_plot, FarmPlotScript.VisualState.GROWING, true, GROWING_SHADOW_PATH, GROWING_COLOR_PATH)
		_verify_transition(farm_plot, FarmPlotScript.VisualState.READY, true, READY_SHADOW_PATH, READY_COLOR_PATH)
		_verify_transition(farm_plot, FarmPlotScript.VisualState.EMPTY, false, "", "")
		_expect(farm_plot.position == original_root_position, "root position changed during cycle %d" % (cycle + 1))
		_expect(plot_base.texture == original_base_texture, "plot base texture changed during cycle %d" % (cycle + 1))
		_expect(plot_base.texture.resource_path == PLOT_BASE_PATH, "plot base path changed during cycle %d" % (cycle + 1))
		_expect([plot_base.get_instance_id(), crop_shadow.get_instance_id(), crop_color.get_instance_id()] == original_node_ids, "a visual node was recreated during cycle %d" % (cycle + 1))
		_expect([plot_base.z_index, crop_shadow.z_index, crop_color.z_index] == original_z_indices, "visual z-order changed during cycle %d" % (cycle + 1))
		_expect(plot_base.get_parent() == farm_plot and crop_shadow.get_parent() == farm_plot and crop_color.get_parent() == farm_plot, "a visual node was reparented during cycle %d" % (cycle + 1))
		_verify_node_transform(plot_base, BASE_POSITION, "PlotBase after cycle %d" % (cycle + 1))
		_verify_node_transform(crop_shadow, EMPTY_CROP_POSITION, "CropShadow after cycle %d" % (cycle + 1))
		_verify_node_transform(crop_color, EMPTY_CROP_POSITION, "CropColor after cycle %d" % (cycle + 1))
		_expect(plot_base.visible, "plot base should remain visible during cycle %d" % (cycle + 1))


func _verify_transition(farm_plot: Node, state: FarmPlotScript.VisualState, crops_visible: bool, shadow_path: String, color_path: String) -> void:
	farm_plot.set_visual_state(state)
	_verify_state(farm_plot, state, crops_visible, shadow_path, color_path)


func _verify_state(farm_plot: Node, state: FarmPlotScript.VisualState, crops_visible: bool, shadow_path: String, color_path: String) -> void:
	var plot_base := farm_plot.get_node(^"PlotBase") as Sprite2D
	var crop_shadow := farm_plot.get_node(^"CropShadow") as Sprite2D
	var crop_color := farm_plot.get_node(^"CropColor") as Sprite2D
	var crop_position := _expected_crop_position(state)
	_verify_node_transform(farm_plot as Node2D, Vector2.ZERO, "FarmPlot in %s" % FarmPlotScript.VisualState.keys()[state])
	_verify_node_transform(plot_base, BASE_POSITION, "PlotBase in %s" % FarmPlotScript.VisualState.keys()[state])
	_verify_node_transform(crop_shadow, crop_position, "CropShadow in %s" % FarmPlotScript.VisualState.keys()[state])
	_verify_node_transform(crop_color, crop_position, "CropColor in %s" % FarmPlotScript.VisualState.keys()[state])
	_expect(crop_shadow.position == crop_color.position, "crop shadow and color should share a position in %s" % FarmPlotScript.VisualState.keys()[state])
	_expect(crop_shadow.position.y == SOIL_CONTACT_Y and crop_color.position.y == SOIL_CONTACT_Y, "crop pair y-coordinate should remain -232.5 in %s" % FarmPlotScript.VisualState.keys()[state])
	_expect(plot_base.z_index == 0 and crop_shadow.z_index == 1 and crop_color.z_index == 2, "visual z-order should remain fixed in %s" % FarmPlotScript.VisualState.keys()[state])
	_expect(farm_plot.get_visual_state() == state, "get_visual_state should return %s" % FarmPlotScript.VisualState.keys()[state])
	_expect(plot_base.visible, "plot base should be visible in %s" % FarmPlotScript.VisualState.keys()[state])
	_expect(plot_base.texture != null and plot_base.texture.resource_path == PLOT_BASE_PATH, "plot base texture should remain exact in %s" % FarmPlotScript.VisualState.keys()[state])
	_expect(crop_shadow.visible == crops_visible, "crop shadow visibility should match %s" % FarmPlotScript.VisualState.keys()[state])
	_expect(crop_color.visible == crops_visible, "crop color visibility should match %s" % FarmPlotScript.VisualState.keys()[state])
	if crops_visible:
		_expect(crop_shadow.texture != null and crop_shadow.texture.resource_path == shadow_path, "crop shadow texture should match %s" % FarmPlotScript.VisualState.keys()[state])
		_expect(crop_color.texture != null and crop_color.texture.resource_path == color_path, "crop color texture should match %s" % FarmPlotScript.VisualState.keys()[state])
	else:
		_expect(crop_shadow.texture == null, "crop shadow texture should be empty in EMPTY")
		_expect(crop_color.texture == null, "crop color texture should be empty in EMPTY")


func _expected_crop_position(state: FarmPlotScript.VisualState) -> Vector2:
	match state:
		FarmPlotScript.VisualState.GROWING:
			return GROWING_CROP_POSITION
		FarmPlotScript.VisualState.READY:
			return READY_CROP_POSITION
		_:
			return EMPTY_CROP_POSITION


func _verify_node_transform(node: Node2D, expected_position: Vector2, description: String) -> void:
	_expect(node.position == expected_position, "%s position should be %s" % [description, expected_position])
	_expect(node.scale == Vector2.ONE, "%s scale should remain (1, 1)" % description)
	_expect(node.rotation == 0.0, "%s rotation should remain zero" % description)
	_expect(node.skew == 0.0, "%s skew should remain zero" % description)


func _expect(condition: bool, description: String) -> void:
	if not condition:
		_failures.append(description)
