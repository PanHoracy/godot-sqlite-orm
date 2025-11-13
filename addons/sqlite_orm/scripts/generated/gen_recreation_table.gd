class_name RecreationTableORM extends "res://common/scrpts/tables/recreation_table.gd"

#TODO Add entry value validation. That is, let entry pass value inside of it to
# column class, for it to validate, if it's correct


class RecreationTableORMSelect:
	extends ORMSelect
	
	var _parent_table: RecreationTableORM
	
	
	func _init(parent_table: RecreationTableORM) -> void:
		_parent_table = parent_table
	
	
	func _get_from_table() -> String:
		return _parent_table.get_name()
	
	
	func _get_selected() -> String:
		return ", ".join(_parent_table.get_all_columns().map(func(c: ORMColumn): return c.get_name_with_table()))
	
	
	func _get_join_clauses() -> String:
		return ""
	
	
	func get_entries() -> Array[RecreationTableORMEntry]:
		var raw_results := get_as_raw_result()
		var entries: Array[RecreationTableORMEntry] = []
		for result in raw_results:
			entries.push_back(RecreationTableORMEntry.wrap_query_result(result))
		return entries
	
	
	func get_first_entry() -> RecreationTableORMEntry:
		_limit = 1
		var entries := get_entries()
		
		return entries[0] if not entries.is_empty() else null
	
	
	#region Recasting base methods
	
	func group_by(...columns: Array) -> RecreationTableORMSelect:
		super.group_by(columns)
		return self
	
	
	func having(condition: ORMCondition) -> RecreationTableORMSelect:
		super.having(condition)
		return self
	
	
	func distinct(value: bool = true) -> RecreationTableORMSelect:
		super.distinct(value)
		return self
	
	
	func where(condition: ORMCondition) -> RecreationTableORMSelect:
		super.where(condition)
		return self
	
	
	func order_by_asc(column: ORMColumn) -> RecreationTableORMSelect:
		super.order_by_asc(column)
		return self
	
	
	func order_by_desc(column: ORMColumn) -> RecreationTableORMSelect:
		super.order_by_desc(column)
		return self
	
	
	func limit(amount: int, offset: int = 0) -> RecreationTableORMSelect:
		super.limit(amount, offset)
		return self
	
	#endregion


func _init() -> void:
	_name = "recreation_table"
	
	renamed_column.name = 'renamed_column'
	column_with_changed_default.name = 'column_with_changed_default'
	column_to_not_null.name = 'column_to_not_null'
	column_to_not_null_with_default.name = 'column_to_not_null_with_default'
	column_to_unique.name = 'column_to_unique'
	id.name = 'id'
	
	
	super._init()


func create_select_query() -> RecreationTableORMSelect:
	return RecreationTableORMSelect.new(self)


func create_update_query() -> ORMUpdate:
	return ORMUpdate.new(self)


func create_delete_query() -> ORMDelete:
	return ORMDelete.new(self)


func put_entries_array_into_table(entries: Array[RecreationTableORMEntry]) -> void:
	DB._get_db().insert_rows(get_name(), entries.map(func(e: RecreationTableORMEntry): return e.get_entry_dict()) as Array[Dictionary])


func put_entry_into_table(entry: RecreationTableORMEntry) -> void:
	DB._get_db().insert_row(get_name(), entry.get_entry_dict())


func get_all() -> Array[RecreationTableORMEntry]:
	var result: Array[RecreationTableORMEntry] = []
	
	var query := "SELECT * FROM %s" % get_name()
	var query_result: Array[Dictionary] = DB._run_query_and_get_result_array(query)
	
	if query_result.is_empty():
		return []
	
	if query_result[0].has("error"):
		push_error("Error while getting all entries. Returning empty array. Error message: %s" % query_result[0]["error"])
		return []
	
	for result_dict in query_result:
		result.push_back(RecreationTableORMEntry.wrap_query_result(result_dict))
	
	return result


func get_by_id(id: int) -> RecreationTableORMEntry:
	var query := "SELECT * FROM %s WHERE id=%s" % [get_name(), id]
	var query_result: Array[Dictionary] = DB._run_query_and_get_result_array(query)
	
	if query_result.is_empty():
		push_warning("Get by id for id %s returned nothing. Returning null" % id)
		return null
	
	if query_result[0].has("error"):
		push_error("Error while getting entry of id %s. Returning null. Error message: %s" % [id, query_result[0]["error"]])
		return null
	
	if query_result.size() > 1:
		push_warning("Get more then one result from get by id. Returning first result")
	
	return RecreationTableORMEntry.wrap_query_result(query_result[0])


func update_by_id(id: int, updated_row: RecreationTableORMEntry) -> bool:
	if updated_row == null:
		push_error("Cannot run update query when updated row is null")
		return false
	
	return DB._get_db().update_rows(
			get_name(),
			"%s.%s = %s" % [get_name(), self.id.name, id],
			updated_row.get_entry_dict()
		)


func delete_by_id(id: int) -> bool:
	return DB._get_db().delete_rows(get_name(), "%s.id = %s" % [get_name(), id])



func get_all_columns() -> Array[ORMColumn]:
	return [renamed_column, column_with_changed_default, column_to_not_null, column_to_not_null_with_default, column_to_unique, id, ]
