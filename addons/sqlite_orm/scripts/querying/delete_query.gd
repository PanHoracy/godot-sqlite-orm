class_name ORMDelete extends ORMQueryWithLimitOrder


func _init(table: ORMTable) -> void:
	super._init(table)


func delete() -> bool:
	if _table == null:
		push_error("Cannot run query without table provided. Aborting query")
		return false
	
	var query := "DELETE FROM %s" % _table.get_name()
	
	if _condition != null:
		query += "\nWHERE %s" % _condition.get_condition()
	if not _ordering.is_empty():
		query += "\nORDER BY %s" % _get_ordering()
	if _limit > 0:
		query += "\nLIMIT %s OFFSET %s" % [_limit, _limit_offset]
	
	print("Entered query:\n%s" % query)
	return DB._run_query(query)


#region Recasting base methods

func where(condition: ORMCondition) -> ORMDelete:
	return super.where(condition) as ORMDelete


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
