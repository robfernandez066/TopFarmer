extends SceneTree

const BalanceLoader = preload("res://autoload/balance.gd")
const BAD_FIXTURE_NAME := "balance_loader_bad.csv"
const BAD_FIXTURE_PATH := "user://" + BAD_FIXTURE_NAME

var _failures: Array[String] = []


func _initialize() -> void:
	var loader := BalanceLoader.new()
	if not loader.load_all(false):
		_failures.append("all balance files should load: %s" % loader.get_last_error())
	else:
		_verify_representative_queries(loader)

	if _write_bad_fixture():
		if loader.validate_file_for_test("crops", BAD_FIXTURE_PATH):
			_failures.append("malformed fixture data should be rejected")
		elif not loader.get_last_error().contains(BAD_FIXTURE_PATH) or not loader.get_last_error().contains(" row "):
			_failures.append("malformed fixture diagnostic should include its source file and row")
	else:
		_failures.append("could not create the malformed test fixture")
	_remove_bad_fixture()
	loader.free()

	if _failures.is_empty():
		print("PASS: all 7 balance files loaded; bad test data was rejected")
		quit()
		return
	for failure in _failures:
		printerr("TEST FAILURE: %s" % failure)
	quit(1)


func _verify_representative_queries(loader: Node) -> void:
	var crop: Dictionary = loader.get_crop("sunwheat")
	_expect(not loader.get_global("GROWTH_TIME_MULT").is_empty(), "global lookup by Key")
	_expect(not crop.is_empty(), "crop lookup by lowercase snake_case id")
	_expect(not loader.get_good("flour").is_empty(), "good lookup by lowercase snake_case id")
	_expect(not loader.get_building("flourmill").is_empty(), "building lookup by lowercase snake_case id")
	if not crop.is_empty():
		_expect(not loader.get_level(crop["unlock_level"]).is_empty(), "progression lookup by integer level")
	_expect(not loader.get_order("ORD_S_01").is_empty(), "order lookup by order_id")
	_expect(not loader.get_currency_rows("gold", "source").is_empty(), "currency lookup by currency and flow")


func _write_bad_fixture() -> bool:
	var source := FileAccess.open("res://data/crops.csv", FileAccess.READ)
	if source == null:
		return false
	var source_text := source.get_as_text()
	source.close()
	var fixture := FileAccess.open(BAD_FIXTURE_PATH, FileAccess.WRITE)
	if fixture == null:
		return false
	fixture.store_string(source_text.trim_suffix("\n") + "\nmalformed_fixture_row\n")
	fixture.close()
	return true


func _remove_bad_fixture() -> void:
	var user_directory := DirAccess.open("user://")
	if user_directory != null and user_directory.file_exists(BAD_FIXTURE_NAME):
		user_directory.remove(BAD_FIXTURE_NAME)


func _expect(condition: bool, description: String) -> void:
	if not condition:
		_failures.append("representative query failed: %s" % description)
