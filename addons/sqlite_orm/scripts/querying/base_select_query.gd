@abstract
class_name ORMSelectBase extends ORMQuery

var _distinct: bool = false
var _group_by_columns: Array[String] = []
var _empty_selection: bool = false
var _empty_from_table: bool = false
var _having_condition: ORMCondition = null


func get_query_string() -> String:
	var pattern := "SELECT %s FROM %s" if not _distinct else "SELECT DISTINCT %s FROM %s"
	
	var selection: String = _get_selected()
	var from_table: String = _get_from_table()
	
	_empty_selection = selection.is_empty()
	_empty_from_table = from_table.is_empty()
	
	var query := pattern % [selection, from_table]
	
	var join_clauses: String = _get_join_clauses()
	if not join_clauses.is_empty():
		query += "\n" + join_clauses
	
	query = _add_where_to_query_string(query)
	
	if not _group_by_columns.is_empty():
		query += "\n" + "GROUP BY " + ", ".join(_group_by_columns)
		
		if _having_condition != null:
			query += "\n" + "HAVING %s " % _having_condition.get_condition()
	else:
		if _having_condition != null:
			push_error("You cannot use having without group by!")
	
	query = _add_order_and_limit_to_query_string(query)
	
	return query


func get_as_raw_result() -> Array[Dictionary]:
	var query: String = get_query_string()
	
	if _empty_selection:
		push_error("Select Query: Nothing was selected")
		return []
	
	if _empty_from_table:
		push_error("Select Query: No from table found")
		return []
	
	print("Entered query:\n%s" % query)
	return DB._run_query_and_get_result_array(query)


@abstract func _get_from_table() -> String


@abstract func _get_selected() -> String


@abstract func _get_join_clauses() -> String


func distinct(value: bool = true) -> ORMSelectBase:
	_distinct = true
	return self


func group_by(columns: Array) -> ORMSelectBase:
	for entry in columns:
		if entry is ORMColumn:
			_group_by_columns.push_back(entry.get_name_with_table())
		elif entry is ORMSelectHelperBase and not entry is ORMSelectAs:
			_group_by_columns.push_back(entry.get_selection_string())
		else:
			push_error("Value passed to group by is invalid")
	
	return self


func having(condition: ORMCondition) -> ORMSelectBase:
	_having_condition = condition
	return self
