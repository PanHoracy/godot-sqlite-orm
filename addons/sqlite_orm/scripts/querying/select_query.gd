class_name ORMSelect extends ORMSelectBase

var _selected: Array[String] = []
var _from_table: String = ""
var _joins: Array[String] = []


func select(...selection: Array) -> ORMSelect:
	if selection.is_empty():
		push_error("Nothing passed to select")
		return
	
	#TODO This needs to be revorked for automatic join table resolution
	
	#var first_entry = selection[0]
	#if first_entry is ORMColumn:
		#_from_table = first_entry.get_table().get_name()
	#elif first_entry is Array[ORMColumn]:
		#if first_entry.is_empty():
			#push_error("Array passed to select is empty")
		#elif first_entry[0] == null:
			#push_error("Array passed to select contains null (can't deduce form table)")
		#else:
			#_from_table = first_entry[0].get_table().get_name()
	#elif first_entry is ORMAggregateFunction:
		#_from_table = first_entry.get_from_table()
	#else:
		#push_error("Unsupported value passed to select (accepted types: ORMColumn)")
	
	for entry in selection:
		if entry is ORMColumn:
			_selected.push_back(entry.get_name_with_table())
		elif entry is Array[ORMColumn]:
			for column: ORMColumn in entry:
				if column == null:
					push_error("Array passed to select contains null")
					continue
				_selected.push_back(column.get_name_with_table())
		elif entry is ORMAggregateFunction:
			_selected.push_back(entry.get_selection_string())
		else:
			push_error("Unsupported value passed to select (accepted types: ORMColumn)")
	
	return self


func from(table: ORMTable) -> ORMSelect:
	_from_table = table.get_name()
	return self


func inner_join(table: ORMTable, on: ORMCondition) -> ORMSelect:
	var join := "INNER JOIN %s ON %s " % [table.get_name(), on.get_condition()]
	_joins.push_back(join)
	
	return self


func left_join(table: ORMTable, on: ORMCondition) -> ORMSelect:
	var join := "LEFT JOIN %s ON %s " % [table.get_name(), on.get_condition()]
	_joins.push_back(join)
	
	return self


func right_join(table: ORMTable, on: ORMCondition) -> ORMSelect:
	var join := "RIGHT JOIN %s ON %s " % [table.get_name(), on.get_condition()]
	_joins.push_back(join)
	
	return self


func cross_join(table: ORMTable) -> ORMSelect:
	var join := "CROSS JOIN %s " % table.get_name()
	_joins.push_back(join)
	
	return self


func full_outer_join(table: ORMTable, on: ORMCondition) -> ORMSelect:
	var join := "FULL OUTER JOIN %s ON %s " % [table.get_name(), on.get_condition()]
	_joins.push_back(join)
	
	return self


func _get_from_table() -> String:
	return _from_table


func _get_selected() -> String:
	return ", ".join(_selected)


func _get_join_clauses() -> String:
	return "\n".join(_joins)


#region Recasting base methods

func group_by(...columns: Array) -> ORMSelect:
	super.group_by(columns)
	return self


func having(condition: ORMCondition) -> ORMSelect:
	super.having(condition)
	return self


func distinct(value: bool = true) -> ORMSelect:
	super.distinct(value)
	return self


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

#endregion
