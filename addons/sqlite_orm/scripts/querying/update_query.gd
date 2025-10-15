class_name ORMUpdate extends ORMQueryWithLimitOrder

var _updated_row: ORMEntry = null


func _init(table: ORMTable) -> void:
	super._init(table)


func set_updated_row(updated_row: ORMEntry) -> ORMUpdate:
	_updated_row = updated_row
	return self


func update() -> bool:
	if _table == null:
		push_error("Cannot run query without table provided. Aborting query")
		return false
	
	if _updated_row == null:
			push_error("Cannot run update query without updated row")
			return false
	
	var pattern := "UPDATE %s SET %s"
	
	var updated_row_dict: Dictionary = _updated_row.get_entry_dict()
	var columns_to_update_string := ""
	var column_array: Array[String] = Array(updated_row_dict.keys(), TYPE_STRING, "", null)
	if not _columns_to_query.is_empty(): 
		column_array = []
		for column_name_with_table in _columns_to_query:
			column_array.push_back(column_name_with_table.split(".")[1])
	
	for column_name in column_array:
		columns_to_update_string += column_name + " = " + str(updated_row_dict[column_name]) + ", "
	columns_to_update_string = columns_to_update_string.substr(0, len(columns_to_update_string)-2)
	
	var query := pattern % [_table.get_name(), columns_to_update_string]
	if _condition != null:
		query += "\nWHERE %s" % _condition.get_condition()
	if not _ordering.is_empty():
		query += "\nORDER BY %s" % _get_ordering()
	if _limit > 0:
		query += "\nLIMIT %s OFFSET %s" % [_limit, _limit_offset]
	
	print("Entered query: %s" % query)
	return DB._get_db().query(query)


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


func select_columns(columns: Array[ORMColumn]) -> ORMUpdate:
	super.select_columns(columns)
	return self

#endregion
