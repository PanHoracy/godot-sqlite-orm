class_name ORMSelect extends ORMQueryWithLimitOrderSelect

var _distinct: bool = false


func _init(table: ORMTable) -> void:
	super._init(table)


func get_as_raw_result() -> Array[Dictionary]:
	return _run_query()


func distinct(value: bool = true) -> ORMSelect:
	_distinct = true
	return self


func _run_query() -> Array[Dictionary]:
	if _table == null:
		push_error("Cannot run query without table provided. Aborting query")
		return []
	
	var pattern := "SELECT %s FROM %s" if not _distinct else "SELECT DISTINCT %s FROM %s"
	
	var columns_to_query_string := ""
	if not _columns_to_query.is_empty():
		for column_name in _columns_to_query:
			columns_to_query_string += column_name + ", "
		columns_to_query_string = columns_to_query_string.substr(0, len(columns_to_query_string)-2)
	else:
		columns_to_query_string = "*"
	
	var query := pattern % [columns_to_query_string, _table.get_name()]
	if _condition != null:
		query += "\nWHERE %s" % _condition.get_condition()
	if not _ordering.is_empty():
		query += "\nORDER BY %s" % _get_ordering()
	if _limit > 0:
		query += "\nLIMIT %s OFFSET %s" % [_limit, _limit_offset]
	
	print("Entered query:\n%s" % query)
	return DB._run_query_and_get_result_array(query)


#region Recasting base methods

func where(condition: ORMCondition) -> ORMSelect:
	super.where(condition)
	return self


func order_by_asc(column: ORMColumn) -> ORMSelect:
	super.order_by_asc(column)
	return self


func order_by_desc(column: ORMColumn) -> ORMSelect:
	super.order_by_desc(column)
	return self


func limit(amount: int, offset: int = 0) -> ORMSelect:
	super.limit(amount, offset)
	return self


func select_columns(columns: Array[ORMColumn]) -> ORMSelect:
	super.select_columns(columns)
	return self

#endregion
