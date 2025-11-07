class_name ORMDelete extends ORMQuery

var _table: ORMTable = null


func _init(table: ORMTable) -> void:
	_table = table


func get_query_string() -> String:
	var query := "DELETE FROM %s"
	
	if is_instance_valid(_table):
		query = query % _table.get_name()
	else:
		query = query % "UNKNOWN"
	
	query = _add_where_to_query_string(query)
	query = _add_order_and_limit_to_query_string(query)
	
	return query


func delete() -> bool:
	if _table == null:
		push_error("Cannot run query without table provided. Aborting query")
		return false
	
	var query := get_query_string()
	
	print("Entered query:\n%s" % query)
	return DB._run_query(query)


#region Recasting base methods

func where(condition: ORMCondition) -> ORMDelete:
	super.where(condition)
	return self


func order_by_asc(column: ORMColumn) -> ORMDelete:
	super.order_by_asc(column)
	return self


func order_by_desc(column: ORMColumn) -> ORMDelete:
	super.order_by_desc(column)
	return self


func limit(amount: int, offset: int = 0) -> ORMDelete:
	super.limit(amount, offset)
	return self

#endregion
