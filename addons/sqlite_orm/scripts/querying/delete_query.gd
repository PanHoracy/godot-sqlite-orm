class_name ORMDelete extends ORMQuery


func _init(table: ORMTable) -> void:
	super._init(table)


func delete() -> bool:
	if _condition == null:
		push_error("Cannot run delete query without condition")
		return false
	
	if _table == null:
		push_error("Cannot run query without table provided. Aborting query")
		return false
	
	return DB._get_db().delete_rows(
		_table.get_name(), 
		_condition.get_condition()
	)


#region Recasting base methods

func where(condition: ORMCondition) -> ORMDelete:
	return super.where(condition) as ORMDelete

#endregion
