# Class name is set here to allow this script to appear in build-in documentation
class_name ORMDatabase extends Node

## Class that is used by main singleton of SQLite ORM plugin.

signal tables_ready

const _UTILS := preload("res://addons/sqlite_orm/scripts/common/utils.gd")

@onready var _tables: Array[ORMTable] = [test_table, recreation_table, producer_table, leaderboard, ]

var _db: SQLite
var _db_path: String
var _verbosity_level: int
var _are_foreign_keys_enabled: bool

class EvaluationResult:
	extends RefCounted
	
	## Tables that have not been found in database
	var missing_tables: Array[ORMTable] = []
	## Names of the tables that have been found in database, 
	## but are not in the list of tables
	var invalid_tables: Array[String] = []
	## Tables (keys) with missing columns (value as array of column names)
	var missing_columns: Dictionary[ORMTable, Array] = {}
	## Similar to the [member missing_columns], but with columns that should not be
	## in given table
	var invalid_columns: Dictionary[ORMTable, Array] = {}
	## Similar to the [member missing_columns], but with columns that have been altered
	var altered_columns: Dictionary[ORMTable, Array] = {}
	
	func _to_string() -> String:
		return "<EvaluationResult: MT(%s) IT(%s) MC(%s) IC(%s) AC(%s)>" % [
			missing_tables.size(),
			invalid_tables.size(),
			missing_columns.size(),
			invalid_columns.size(),
			altered_columns.size()
		]

#region Tables
var test_table: TestTableORM = TestTableORM.new()
var recreation_table: RecreationTableORM = RecreationTableORM.new()
var product_table: ProductTableORM
var product_review: ProductReviewORM
var producer_table: ProducerTableORM = ProducerTableORM.new()
var leaderboard: LeaderboardORM = LeaderboardORM.new()
#endregion

func _initialize_fk_tables() -> void:
	product_table = ProductTableORM.new()
	_tables.append(product_table)
	product_review = ProductReviewORM.new()
	_tables.append(product_review)
	tables_ready.emit()

#region Exposed to users

## Get name list of all tables created in current database. Can be used for debugging
func get_created_tables() -> Array[String]:
	var result: Array[String] = []
	var query: String = "SELECT name FROM sqlite_master WHERE type='table' AND name!='sqlite_sequence';"
	
	if not _run_query(query):
		return []
	
	result.append_array(_db.query_result.map(func(d): return d["name"]))
	return result

## Get the desctiption of a table with a given name ([param table_name]).
## It returns dictionary describing the table in the same format as table_dict
## in Sqlite extension create_table method. Can be used for debugging
func get_table_schema(table_name: String) -> Dictionary[String, Dictionary]:
	# Read information about table
	var query: String = "pragma table_info('%s');" % table_name
	if not _run_query(query):
		return {}
	
	var result: Dictionary[String, Dictionary] = {}
	
	for column_dict in _db.query_result:
		var column_name: String = column_dict["name"]
		var data_type := ""
		var default_value = column_dict["dflt_value"]
		match column_dict["type"]:
			"INTEGER":
				data_type = "int"
				if default_value != null:
					default_value = int(default_value)
			"REAL":
				data_type = "real"
				if default_value != null:
					default_value = float(default_value)
			"TEXT":
				data_type = "text"
			"BLOB":
				data_type = "blob"
				if default_value != null:
					#FIXME This will probably not work
					default_value = PackedByteArray(default_value)
			_:
				assert(false, "Unreacognized type")
		var not_null: bool = column_dict["notnull"] == 1
		var primary_key: bool = column_dict["pk"] == 1
		
		result[column_name] = {
			"data_type": data_type,
			"not_null": not_null,
			"default": default_value,
			"primary_key": primary_key,
			"foreign_key": null
		}
	
	# Read information that is not availabe in pragma (unique, autoincrement)
	query = "select sql from sqlite_schema where name = '%s';" % table_name
	if not _run_query(query):
		return {}
	
	# Extract information about columns, and split into dictionary, with column name
	# as key
	var sql_text: String = _db.query_result[0]["sql"]
	var start: int = sql_text.find("(")+1
	sql_text = sql_text.substr(start, sql_text.rfind(")")-start)
	var columns_sql: Array[String] = Array(Array(sql_text.split(",")).map(func(s: String): return s.strip_edges()), TYPE_STRING, "", null)
	var columns_sql_dict := {}
	var pk_constrains: Array[String] = []
	var fk_constrains: Array[String] = []
	for text in columns_sql:
		var text_formated := text.replace("\"", "")
		text_formated = text_formated.replace("\t", " ")
		if text_formated.begins_with("PRIMARY KEY"):
			pk_constrains.push_back(text_formated)
		elif text_formated.begins_with("FOREIGN KEY"):
			fk_constrains.push_back(text_formated)
		else:
			var column_name := text_formated.substr(0, text_formated.find(" "))
			columns_sql_dict[column_name] = text_formated.substr(text_formated.find(" ")).strip_edges()
	
	for column_name in result.keys():
		result[column_name]["unique"] = columns_sql_dict[column_name].contains("UNIQUE")
		result[column_name]["auto_increment"] = columns_sql_dict[column_name].contains("AUTOINCREMENT")
	
	for pk_text in pk_constrains:
		start = pk_text.find("(")+1
		var text := pk_text.substr(start, pk_text.rfind(")")-start)
		var parts := text.split(" ")
		if parts.size() >= 2:
			result[parts[0]]["auto_increment"] = parts[1] == "AUTOINCREMENT"
	
	for fk_text in fk_constrains:
		var parts := fk_text.split(" ")
		var column_name := parts[2].replace("(", "").replace(")", "")
		var references := parts[4].replace("(", ".").replace(")", "")
		result[column_name]["foreign_key"] = references
	
	return result

#endregion

#region Exposed to the rest of the plugin

## Get direct access to SQLite Object. Should only be used by plugin, but 
## if you know what you are doing, you are welcome to use it as well I guess
func _get_db() -> SQLite:
	return _db


func _run_query_and_get_result_array(query: String) -> Array[Dictionary]:
	_db.query(query)
	
	if _db.error_message != "not an error":
		return [{"error": _db.error_message}]
	
	return _db.query_result

#endregion

func _enter_tree() -> void:
	_UTILS.update_plugin_settings()


func _ready() -> void:
	_load_settings()
	
	_db = SQLite.new()
	_db.path = _db_path
	_db.verbosity_level = _verbosity_level
	_db.foreign_keys = _are_foreign_keys_enabled
	
	var success := _db.open_db()
	if not success:
		push_error("There was an error while opening the database")
	
	_initialize_fk_tables()
	
	var evaluation_result: EvaluationResult = _evaluate_database()
	print(evaluation_result)
	
	if not evaluation_result.missing_tables.is_empty():
		_create_tables(evaluation_result.missing_tables)
	if not evaluation_result.invalid_tables.is_empty():
		_remove_tables(evaluation_result.invalid_tables)
		
	var tables_to_recreate: Dictionary[ORMTable, Array] = {}
	if not evaluation_result.missing_columns.is_empty():
		for table: ORMTable in evaluation_result.missing_columns.keys():
			if not tables_to_recreate.has(table):
				tables_to_recreate[table] = evaluation_result.missing_columns[table]
			else:
				tables_to_recreate[table].append_array(evaluation_result.missing_columns[table])
	if not evaluation_result.invalid_columns.is_empty():
		for table: ORMTable in evaluation_result.invalid_columns.keys():
			if not tables_to_recreate.has(table):
				tables_to_recreate[table] = evaluation_result.invalid_columns[table]
			else:
				tables_to_recreate[table].append_array(evaluation_result.invalid_columns[table])
	if not evaluation_result.altered_columns.is_empty():
		for table: ORMTable in evaluation_result.altered_columns.keys():
			if not tables_to_recreate.has(table):
				tables_to_recreate[table] = evaluation_result.altered_columns[table]
			else:
				tables_to_recreate[table].append_array(evaluation_result.altered_columns[table])
	
	for table: ORMTable in tables_to_recreate.keys():
		_recreate_table_preserve_data(table, Array(tables_to_recreate[table], TYPE_STRING, "", null))


func _evaluate_database() -> EvaluationResult:
	var created_tables: Array[String] = get_created_tables()
	var result := EvaluationResult.new()
	
	# When there are no tables, assume that database was freshly created
	if created_tables.is_empty():
		result.missing_tables = _tables
		return result
	
	for table in _tables:
		if not created_tables.has(table.get_name()):
			result.missing_tables.append(table)
			continue
		
		created_tables.erase(table.get_name())
		
		var table_dict: Dictionary = table.get_table_dict()
		var database_table_dict: Dictionary = get_table_schema(table.get_name())
		var missing_columns: Array[String] = []
		var altered_columns: Array[String] = []
		var invalid_columns: Array[String] = []
		
		for column_name in table_dict.keys():
			if not database_table_dict.has(column_name):
				missing_columns.append(column_name)
				continue
			
			for property in table_dict[column_name]:
				if not database_table_dict[column_name].has(property):
					push_error("Read table (%s) dictionary doesn't have property of %s" % [table.get_name(), property])
					continue
				
				if not table_dict[column_name][property] == database_table_dict[column_name][property]:
					altered_columns.append(column_name)
					break
			
			database_table_dict.erase(column_name)
		
		# If there is any column left it means it shouldn't be there
		invalid_columns = Array(database_table_dict.keys(), TYPE_STRING, "", null)
		
		if not missing_columns.is_empty():
			result.missing_columns[table] = missing_columns
		
		if not invalid_columns.is_empty():
			result.invalid_columns[table] = invalid_columns
		
		if not altered_columns.is_empty():
			result.altered_columns[table] = altered_columns
	
	# If there is any table left it meas it shouldn't be there
	result.invalid_tables = created_tables
	
	return result


func _recreate_table_preserve_data(table: ORMTable, altered_columns: Array[String]) -> void:
	#TODO Add options to controll how recreation is performed (or to skip it entirely)
	print("Recreate table %s, with altered columns %s" % [table, altered_columns])
	
	var query := "SELECT * FROM %s" % table.get_name()
	var table_content := _run_query_and_get_result_array(query)
	
	_db.drop_table(table.get_name())
	_db.create_table(table.get_name(), table.get_table_dict())
	
	var insert_rows: Array[Dictionary] = []
	var columns: Array[ORMColumn] = table.get_all_columns()
	var columns_dict := table.get_table_dict()
	
	var default_values: Dictionary[String, Variant] = {}
	for column in columns:
		default_values[column.name] = columns_dict[column.name]["default"] if columns_dict[column.name].has("default") else null
	
	for old_row in table_content:
		var new_row := {}
		for column in columns:
			var names: Array[String] = column.get_old_names()
			names.push_back(column.name)
			
			for cname in names:
				if old_row.has(cname):
					new_row[column.name] = old_row[cname]
			
			if not new_row.has(column.name):
				new_row[column.name] = default_values[column.name]
		insert_rows.push_back(new_row)
	
	var rows_to_ommit: Array[int] = []
	var unique_rows_values: Dictionary[String, Array] = {}
	for column in columns:
		if columns_dict[column.name]["unique"]:
			unique_rows_values[column.name] = []
	
	for row_id in insert_rows.size():
		var row: Dictionary = insert_rows[row_id]
		for column in columns:
			var column_dict: Dictionary = columns_dict[column.name]
			var value = row[column.name]
			
			if columns_dict[column.name]["data_type"] == "int":
				if value is not int:
					value = default_values[column.name]
			elif columns_dict[column.name]["data_type"] == "real":
				if value is not float:
					value = default_values[column.name]
			elif columns_dict[column.name]["data_type"] == "text":
				if value is not String:
					value = default_values[column.name]
			elif columns_dict[column.name]["data_type"] == "blob":
				if value is not PackedByteArray:
					value = default_values[column.name]
			
			if column_dict["not_null"]:
				if value == null:
					if default_values[column.name] == null:
						rows_to_ommit.push_back(row_id)
						print("- Row:\n%s\n will not be moved to recereated table because it does not meet the not null constraint on column %s" % [table_content[row_id], column.name])
						break
					else:
						print("- Row:\n%s\n value on %s column will be set to default value to meet not null constraint")
						value = default_values[column.name]
			
			if column_dict["unique"]:
				if unique_rows_values[column.name].has(value):
					rows_to_ommit.push_back(row_id)
					print("- Row:\n%s\n will not be moved to recereated table because it does not meet the unique constraint on column %s" % [table_content[row_id], column.name])
					break
				else:
					unique_rows_values[column.name].push_back(value)
	
	var final_insert_rows: Array[Dictionary] = []
	for id in insert_rows.size():
		if not rows_to_ommit.has(id):
			final_insert_rows.push_back(insert_rows[id])
	
	_db.insert_rows(table.get_name(), final_insert_rows)


func _create_tables(tables: Array[ORMTable]) -> void:
	for table in tables:
		print("Creating table %s" % table.get_name())
		_db.create_table(table.get_name(), table.get_table_dict())


func _remove_tables(table_names: Array[String]) -> void:
	for table_name in table_names:
		print("Dropping table %s" % table_name)
		_db.drop_table(table_name)


func _exit_tree() -> void:
	_db.close_db()


func _load_settings() -> void:
	_db_path = ProjectSettings.get_setting(_UTILS.DATABASE_PATH_SP)
	_verbosity_level = ProjectSettings.get_setting(_UTILS.VERBOSITY_LEVEL_SP)
	_are_foreign_keys_enabled = ProjectSettings.get_setting(_UTILS.ENABLE_FOREIGN_KEYS)


func _run_query(query: String) -> bool:
	var success := _db.query(query)
	
	if not success:
		push_error("Error while running query (%s): %s" % [query, _db.error_message])
	
	return success


#region Select Helper methods

func AS(column: Variant, alias: String) -> ORMAggregateFunction:
	return ORMAggregateFunction.new("{column} AS {alias}", column, ["alias", alias])


func AVG(column: Variant) -> ORMAggregateFunction:
	return ORMAggregateFunction.new("AVG(column)", column)


func COUNT(column: Variant) -> ORMAggregateFunction:
	return ORMAggregateFunction.new("COUNT({column})", column)


func MAX(column: Variant) -> ORMAggregateFunction:
	return ORMAggregateFunction.new("MAX({column})", column)


func MIN(column: Variant) -> ORMAggregateFunction:
	return ORMAggregateFunction.new("MIN({column})", column)


func SUM(column: Variant) -> ORMAggregateFunction:
	return ORMAggregateFunction.new("SUM({column})", column)


func GROUP_CONCAT(column: Variant, separator: String = ",") -> ORMAggregateFunction:
	return ORMAggregateFunction.new("GROUP_CONCAT({column}, '{separator}')", column, ["separator", separator])

#endregion
