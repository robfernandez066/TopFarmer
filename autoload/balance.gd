extends Node

const DATA_ROOT := "res://data/"
const TABLE_ORDER := [
	"globals",
	"crops",
	"goods",
	"buildings",
	"progression",
	"orders",
	"currencies",
]
const TABLE_DEFINITIONS := {
	"globals": {
		"file": "globals.csv",
		"headers": ["Key", "Value", "Unit", "Notes"],
		"key_field": "Key",
		"nonempty_fields": ["Key", "Unit"],
		"int_fields": [],
		"float_fields": ["Value"],
		"snake_case_fields": [],
		"optional_snake_case_fields": [],
	},
	"crops": {
		"file": "crops.csv",
		"headers": [
			"id", "name", "unlock_level", "seed_cost", "growth_sec_base",
			"growth_sec_eff", "yield_qty", "sell_price_base", "sell_price_eff",
			"xp_base", "xp_eff", "revenue_per_harvest", "profit_per_harvest",
			"gold_per_hour", "xp_per_hour",
		],
		"key_field": "id",
		"nonempty_fields": ["id", "name"],
		"int_fields": [
			"unlock_level", "seed_cost", "growth_sec_base", "growth_sec_eff",
			"yield_qty", "sell_price_base", "sell_price_eff", "xp_base", "xp_eff",
			"revenue_per_harvest", "profit_per_harvest", "gold_per_hour", "xp_per_hour",
		],
		"float_fields": [],
		"snake_case_fields": ["id"],
		"optional_snake_case_fields": [],
	},
	"goods": {
		"file": "goods.csv",
		"headers": [
			"id", "name", "building_id", "unlock_level", "input1_id", "input1_qty",
			"input2_id", "input2_qty", "prod_sec_base", "prod_sec_eff", "output_qty",
			"sell_price_base", "sell_price_eff", "xp_base", "xp_eff", "input_cost",
			"revenue", "margin", "gold_per_hour", "xp_per_hour",
		],
		"key_field": "id",
		"nonempty_fields": ["id", "name", "building_id", "input1_id"],
		"int_fields": [
			"unlock_level", "input1_qty", "input2_qty", "prod_sec_base", "prod_sec_eff",
			"output_qty", "sell_price_base", "sell_price_eff", "xp_base", "xp_eff",
			"input_cost", "revenue", "margin", "gold_per_hour", "xp_per_hour",
		],
		"float_fields": [],
		"snake_case_fields": ["id", "building_id", "input1_id"],
		"optional_snake_case_fields": ["input2_id"],
	},
	"buildings": {
		"file": "buildings.csv",
		"headers": ["id", "name", "unlock_level", "gold_cost", "build_sec", "slots", "notes"],
		"key_field": "id",
		"nonempty_fields": ["id", "name"],
		"int_fields": ["unlock_level", "gold_cost", "build_sec", "slots"],
		"float_fields": [],
		"snake_case_fields": ["id"],
		"optional_snake_case_fields": [],
	},
	"progression": {
		"file": "progression.csv",
		"headers": ["level", "xp_to_reach", "cumulative_xp", "plots_unlocked", "storage_cap", "unlocks"],
		"key_field": "level",
		"nonempty_fields": ["unlocks"],
		"int_fields": ["level", "xp_to_reach", "cumulative_xp", "plots_unlocked", "storage_cap"],
		"float_fields": [],
		"snake_case_fields": [],
		"optional_snake_case_fields": [],
	},
	"orders": {
		"file": "orders.csv",
		"headers": [
			"order_id", "type", "min_level", "item1_id", "qty1", "item2_id", "qty2",
			"item3_id", "qty3", "goods_value", "gold_reward", "xp_reward", "starlight_reward",
		],
		"key_field": "order_id",
		"nonempty_fields": ["order_id", "type", "item1_id"],
		"int_fields": [
			"min_level", "qty1", "qty2", "qty3", "goods_value", "gold_reward",
			"xp_reward", "starlight_reward",
		],
		"float_fields": [],
		"snake_case_fields": ["type", "item1_id"],
		"optional_snake_case_fields": ["item2_id", "item3_id"],
	},
	"currencies": {
		"file": "currencies.csv",
		"headers": ["currency", "flow", "source_or_sink", "amount", "notes"],
		"key_field": "",
		"nonempty_fields": ["currency", "flow", "source_or_sink", "amount"],
		"int_fields": [],
		"float_fields": [],
		"snake_case_fields": ["currency", "flow"],
		"optional_snake_case_fields": [],
	},
}

var _globals: Dictionary = {}
var _crops: Dictionary = {}
var _goods: Dictionary = {}
var _buildings: Dictionary = {}
var _progression: Dictionary = {}
var _orders: Dictionary = {}
var _currencies: Dictionary = {}
var _last_error := ""


func _ready() -> void:
	if not load_all(true):
		get_tree().quit(1)


func load_all(report_errors := true) -> bool:
	var loaded_tables: Dictionary = {}
	for table_name in TABLE_ORDER:
		var definition: Dictionary = TABLE_DEFINITIONS[table_name]
		var source_path := DATA_ROOT + String(definition["file"])
		var result := _read_table(String(table_name), source_path, report_errors)
		if not result["ok"]:
			return false
		loaded_tables[table_name] = result["rows"]

	_globals = _index_rows(loaded_tables["globals"], "Key")
	_crops = _index_rows(loaded_tables["crops"], "id")
	_goods = _index_rows(loaded_tables["goods"], "id")
	_buildings = _index_rows(loaded_tables["buildings"], "id")
	_progression = _index_rows(loaded_tables["progression"], "level")
	_orders = _index_rows(loaded_tables["orders"], "order_id")
	_currencies = _group_currency_rows(loaded_tables["currencies"])
	_last_error = ""
	return true


func validate_file_for_test(table_name: String, source_path: String) -> bool:
	if not TABLE_DEFINITIONS.has(table_name):
		_fail(source_path, 0, "unknown balance table '%s'" % table_name, false)
		return false
	return _read_table(table_name, source_path, false)["ok"]


func get_last_error() -> String:
	return _last_error


func get_global(key: String) -> Dictionary:
	return _copy_row(_globals.get(key, {}))


func get_crop(id: String) -> Dictionary:
	return _copy_row(_crops.get(id, {}))


func get_good(id: String) -> Dictionary:
	return _copy_row(_goods.get(id, {}))


func get_building(id: String) -> Dictionary:
	return _copy_row(_buildings.get(id, {}))


func get_level(level: int) -> Dictionary:
	return _copy_row(_progression.get(level, {}))


func get_order(order_id: String) -> Dictionary:
	return _copy_row(_orders.get(order_id, {}))


func get_currency_rows(currency: String, flow: String) -> Array:
	var flows: Dictionary = _currencies.get(currency, {})
	var rows: Array = flows.get(flow, [])
	var copied_rows: Array = []
	for row in rows:
		copied_rows.append((row as Dictionary).duplicate(true))
	return copied_rows


func _read_table(table_name: String, source_path: String, report_errors: bool) -> Dictionary:
	var file := FileAccess.open(source_path, FileAccess.READ)
	if file == null:
		return _fail(
			source_path,
			0,
			"could not open file (error %s)" % error_string(FileAccess.get_open_error()),
			report_errors
		)
	if file.get_length() == 0:
		return _fail(source_path, 1, "file is empty", report_errors)

	var definition: Dictionary = TABLE_DEFINITIONS[table_name]
	var headers := file.get_csv_line()
	var header_names: Dictionary = {}
	for header in headers:
		var header_name := String(header)
		if header_names.has(header_name):
			return _fail(source_path, 1, "duplicate header '%s'" % header_name, report_errors)
		header_names[header_name] = true
	for required_header in definition["headers"]:
		if not header_names.has(required_header):
			return _fail(source_path, 1, "missing required header '%s'" % required_header, report_errors)

	var rows: Array = []
	var seen_keys: Dictionary = {}
	var row_number := 1
	while file.get_position() < file.get_length():
		row_number += 1
		var values := file.get_csv_line()
		if values.size() != headers.size():
			return _fail(
				source_path,
				row_number,
				"malformed row: expected %d columns but found %d" % [headers.size(), values.size()],
				report_errors
			)

		var row: Dictionary = {}
		for column_index in range(headers.size()):
			row[String(headers[column_index])] = String(values[column_index]).strip_edges()

		for field in definition["nonempty_fields"]:
			if String(row[field]).is_empty():
				return _fail(source_path, row_number, "required field '%s' is empty" % field, report_errors)

		for field in definition["snake_case_fields"]:
			if not _is_lowercase_snake_case(String(row[field])):
				return _fail(source_path, row_number, "field '%s' is not a lowercase snake_case ID" % field, report_errors)
		for field in definition["optional_snake_case_fields"]:
			var optional_id := String(row[field])
			if not optional_id.is_empty() and not _is_lowercase_snake_case(optional_id):
				return _fail(source_path, row_number, "field '%s' is not a lowercase snake_case ID" % field, report_errors)

		for field in definition["int_fields"]:
			var int_text := String(row[field])
			if not int_text.is_valid_int():
				return _fail(source_path, row_number, "invalid integer in field '%s': '%s'" % [field, int_text], report_errors)
			row[field] = int_text.to_int()
		for field in definition["float_fields"]:
			var float_text := String(row[field])
			if not float_text.is_valid_float():
				return _fail(source_path, row_number, "invalid number in field '%s': '%s'" % [field, float_text], report_errors)
			row[field] = float_text.to_float()

		var key_field := String(definition["key_field"])
		if not key_field.is_empty():
			var key: Variant = row[key_field]
			if seen_keys.has(key):
				return _fail(
					source_path,
					row_number,
					"duplicate key '%s' in field '%s' (first seen at row %d)" % [key, key_field, seen_keys[key]],
					report_errors
				)
			seen_keys[key] = row_number
		rows.append(row)

	return {"ok": true, "rows": rows}


func _fail(source_path: String, row_number: int, message: String, report_errors: bool) -> Dictionary:
	_last_error = "%s row %d: %s" % [source_path, row_number, message]
	if report_errors:
		push_error(_last_error)
	return {"ok": false, "rows": []}


func _index_rows(rows: Array, key_field: String) -> Dictionary:
	var indexed: Dictionary = {}
	for row in rows:
		indexed[(row as Dictionary)[key_field]] = row
	return indexed


func _group_currency_rows(rows: Array) -> Dictionary:
	var grouped: Dictionary = {}
	for row in rows:
		var currency := String((row as Dictionary)["currency"])
		var flow := String((row as Dictionary)["flow"])
		var flows: Dictionary = grouped.get(currency, {})
		var flow_rows: Array = flows.get(flow, [])
		flow_rows.append(row)
		flows[flow] = flow_rows
		grouped[currency] = flows
	return grouped


func _copy_row(row: Dictionary) -> Dictionary:
	return row.duplicate(true)


func _is_lowercase_snake_case(value: String) -> bool:
	if value.is_empty() or value != value.to_lower():
		return false
	if value.begins_with("_") or value.ends_with("_") or value.contains("__"):
		return false
	var first_character := value.left(1)
	if first_character < "a" or first_character > "z":
		return false
	for character in value:
		if (character < "a" or character > "z") and (character < "0" or character > "9") and character != "_":
			return false
	return true
