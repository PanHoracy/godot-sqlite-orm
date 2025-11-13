class_name ORMUpdate extends ORMQuery

var _table: ORMTable = null
var _values_to_set: Dictionary[String, String] = {}


func _init(table: ORMTable) -> void:
	_table = table


func get_query_string() -> String:
	var pattern := "UPDATE %s SET %s"
	var table_name := _table.get_name() if is_instance_valid(_table) else "UNKNOWN"
	
	var set_string := ""
	for column_name in _values_to_set:
		set_string += column_name + " = " + _values_to_set[column_name] + ", "
	set_string = set_string.substr(0, set_string.length()-2)
	
	var query := pattern % [table_name, set_string]
	query = _add_where_to_query_string(query)
	query = _add_order_and_limit_to_query_string(query)
	
	return query


func update() -> bool:
	if _table == null:
		push_error("Cannot run query without table provided. Aborting query")
		return false
	
	if _values_to_set.is_empty():
		push_error("Cannot run query with no value to set. Aborting query")
		return false
	
	var query := get_query_string()
	
	print("Entered query:\n%s" % query)
	return DB._run_query(query)


func set_value(column: ORMColumn, value: Variant) -> ORMUpdate:
	if column.get_table() != _table:
		push_error("You can update only columns from table passed to init. This set will be aborted")
		return self
	
	#OPTION Could add here a check that would prevent user form entering invalid data
	if value == null:
		_values_to_set[column.name] = "NULL"
	else:
		_values_to_set[column.name] = str(value)
	
	return self


func set_entry(updated_row: ORMEntry) -> ORMUpdate:
	#OPTION Add check if entry is from correct table
	
	var entry_dict: Dictionary = updated_row.get_entry_dict()
	for column_name in entry_dict.keys():
		_values_to_set[column_name] = str(entry_dict[column_name])
	
	return self


#region Recasting base methods

func where(condition: ORMCondition) -> ORMUpdate:
	super.where(condition)
	return self


func order_by_asc(column: ORMColumn) -> ORMUpdate:
	super.order_by_asc(column)
	return self


func order_by_desc(column: ORMColumn) -> ORMUpdate:
	super.order_by_desc(column)
	return self


func limit(amount: int, offset: int = 0) -> ORMUpdate:
	super.limit(amount, offset)
	return self

#endregion
