# Class name is set here to allow this script to appear in build-in documentation
class_name Database extends Node

## Class that is used by main singleton of SQLite ORM plugin.

#TODO rename to ORMDatabase

const _UTILS := preload("res://addons/sqlite_orm/scripts/common/utils.gd")

@onready var _tables: Array[Table] = [test_table, product_table, missing_table, ]

var _db: SQLite
var _db_path: String
var _verbosity_level: int

class EvaluationResult:
	extends RefCounted
	
	## Tables that have not been found in database
	var missing_tables: Array[Table] = []
	## Names of the tables that have been found in database, 
	## but are not in the list of tables
	var invalid_tables: Array[String] = []
	## Tables (keys) with missing columns (value as array of column names)
	var missing_columns: Dictionary[Table, Array] = {}
	## Similar to the [member missing_columns], but with columns that should not be
	## in given table
	var invalid_columns: Dictionary[Table, Array] = {}
	## Similar to the [member missing_columns], but with columns that have been altered
	var altered_columns: Dictionary[Table, Array] = {}
	
	func _to_string() -> String:
		return "<EvaluationResult: MT(%s) IT(%s) MC(%s) IC(%s) AC(%s)>" % [
			missing_tables.size(),
			invalid_tables.size(),
			missing_columns.size(),
			invalid_columns.size(),
			altered_columns.size()
		]

#region Tables
var test_table := TestTableORM.new()
var product_table := ProductTableORM.new()
var missing_table := MissingTableORM.new()
#endregion

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
		match column_dict["type"]:
			"INTEGER":
				data_type = "int"
			"REAL":
				data_type = "real"
			"TEXT":
				data_type = "text"
			"BLOB":
				data_type = "blob"
			_:
				assert(false, "Unreacognized type")
		var not_null: bool = column_dict["notnull"] == 1
		var primary_key: bool = column_dict["pk"] == 1
		
		result[column_name] = {
			"data_type": data_type,
			"not_null": not_null,
			"default": column_dict["dflt_value"],
			"primary_key": primary_key
		}
	
	# Read information that is not availabe in pragma (unique, autoincrement)
	query = "select sql from sqlite_schema where name = '%s';" % table_name
	if not _run_query(query):
		return {}
	
	# Extract information about columns, and split into dictionary, with column name
	# as key
	var sql_text: String = _db.query_result[0]["sql"]
	var start: int = sql_text.find("(")+1
	sql_text = sql_text.substr(start, sql_text.find(")")-start)
	var columns_sql: Array[String] = Array(Array(sql_text.split(",")).map(func(s: String): return s.strip_edges()), TYPE_STRING, "", null)
	var columns_sql_dict := {}
	for text in columns_sql:
		var column_name := text.substr(0, text.find(" "))
		columns_sql_dict[column_name] = text.substr(text.find(" ")).strip_edges()
	
	for column_name in result.keys():
		result[column_name]["unique"] = columns_sql_dict[column_name].contains("UNIQUE")
		result[column_name]["auto_increment"] = columns_sql_dict[column_name].contains("AUTOINCREMENT")
	
	return result

#endregion

#region: Exposed to the rest of the plugin

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
	_db.foreign_keys = true
	
	var success := _db.open_db()
	if not success:
		push_error("There was an error while opening the database")
	
	var evaluation_result: EvaluationResult = _evaluate_database()
	print(evaluation_result)
	#TODO add more ways to handle cases of altered database
	if not evaluation_result.missing_tables.is_empty():
		_create_tables(evaluation_result.missing_tables)
	if not evaluation_result.invalid_tables.is_empty():
		_remove_tables(evaluation_result.invalid_tables)
		
	var tables_to_recreate: Dictionary[Table, Array] = {}
	if not evaluation_result.missing_columns.is_empty():
		for table: Table in evaluation_result.missing_columns.keys():
			if not tables_to_recreate.has(table):
				tables_to_recreate[table] = []
	if not evaluation_result.invalid_columns.is_empty():
		for table: Table in evaluation_result.invalid_columns.keys():
			if not tables_to_recreate.has(table):
				tables_to_recreate[table] = []
	if not evaluation_result.altered_columns.is_empty():
		for table: Table in evaluation_result.altered_columns.keys():
			if not tables_to_recreate.has(table):
				tables_to_recreate[table] = [evaluation_result.altered_columns[table]]
			else:
				tables_to_recreate[table].append_array(evaluation_result.altered_columns[table])
	
	for table: Table in tables_to_recreate.keys():
		print(tables_to_recreate[table])
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
					push_error("Read table dictionary doesn't have property of %s" % property)
					continue
				
				#HACK all default values from get_table_schema are strings, but probably
				# should be casted to correct type. For now here I convert both to str
				# until that is done
				if not str(table_dict[column_name][property]) == str(database_table_dict[column_name][property]):
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


func _recreate_table_preserve_data(table: Table, altered_columns: Array[String]) -> void:
	#TODO Implement table recreating with current entries evaluation to fit new schema
	# this can be done only after data insertion is imlepemented
	print("Recreate table %s, with altered columns %s" % [table, altered_columns])


func _create_tables(tables: Array[Table]) -> void:
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


func _run_query(query: String) -> bool:
	var success := _db.query(query)
	
	if not success:
		push_error("Error while running query (%s): %s" % [query, _db.error_message])
	
	return success
