class_name MissingTableORM extends "res://common/scrpts/tables/missing_table.gd"

#TODO Add entry value validation. That is, let entry pass value inside of it to
# column class, for it to validate, if it's correct


class MissingTableORMSelect:
	extends ORMSelect
	
	
	func _init(table: ORMTable) -> void:
		super._init(table)
	
	
	func get_entries() -> Array[MissingTableORMEntry]:
		var raw_results := get_as_raw_result()
		var entries: Array[MissingTableORMEntry] = []
		for result in raw_results:
			entries.push_back(MissingTableORMEntry.wrap_query_result(result))
		return entries
	
	
	func get_first_entry() -> MissingTableORMEntry:
		_limit = 1
		var entries := get_entries()
		
		return entries[0] if not entries.is_empty() else null
	
	
	#region Recasting base methods
	
	func where(condition: ORMCondition) -> MissingTableORMSelect:
		return super.where(condition) as MissingTableORMSelect
	
	
	func order_by_asc(column: ORMColumn) -> MissingTableORMSelect:
		return super.order_by_asc(column) as MissingTableORMSelect
	
	
	func order_by_desc(column: ORMColumn) -> MissingTableORMSelect:
		return super.order_by_desc(column) as MissingTableORMSelect
	
	
	func limit(amount: int, offset: int = 0) -> MissingTableORMSelect:
		return super.limit(amount, offset) as MissingTableORMSelect
	
	
	func select_columns(columns: Array[ORMColumn]) -> MissingTableORMSelect:
		return super.select_columns(columns) as MissingTableORMSelect
	
	
	func distinct(value: bool = true) -> MissingTableORMSelect:
		return super.distinct(value) as MissingTableORMSelect
	
	#endregion


class MissingTableORMUpdate:
	extends ORMQuery
	
	var _updated_row: MissingTableORMEntry = null
	
	
	func _init(table: ORMTable) -> void:
		super._init(table)
	
	
	func set_row(updated_row: MissingTableORMEntry) -> MissingTableORMUpdate:
		_updated_row = updated_row
		return self
	
	
	func update() -> bool:
		if _updated_row == null:
			push_error("Cannot run update query without updated row")
			return false
		
		return DB._get_db().update_rows(
			_table.get_name(),
			_condition.get_condition(),
			_updated_row.get_entry_dict()
		)
	
	
	#region Recasting base methods
	
	func where(condition: ORMCondition) -> MissingTableORMUpdate:
		return super.where(condition) as MissingTableORMUpdate
	
	
	func order_by_asc(column: ORMColumn) -> MissingTableORMUpdate:
		return super.order_by_asc(column) as MissingTableORMUpdate
	
	
	func order_by_desc(column: ORMColumn) -> MissingTableORMUpdate:
		return super.order_by_desc(column) as MissingTableORMUpdate
	
	
	func limit(amount: int, offset: int = 0) -> MissingTableORMUpdate:
		return super.limit(amount, offset) as MissingTableORMUpdate
	
	#endregion


func _init() -> void:
	_name = "missing_table"
	
	test.name = 'test'
	missing_column.name = 'missing_column'
	id.name = 'id'
	
	
	super._init()


func create_select_query() -> MissingTableORMSelect:
	return MissingTableORMSelect.new(self)


func create_update_query() -> MissingTableORMUpdate:
	return MissingTableORMUpdate.new(self)


func put_entries_array_into_table(entries: Array[MissingTableORMEntry]) -> void:
	DB._get_db().insert_rows(get_name(), entries.map(func(e: MissingTableORMEntry): return e.get_entry_dict()) as Array[Dictionary])


func put_entry_into_table(entry: MissingTableORMEntry) -> void:
	DB._get_db().insert_row(get_name(), entry.get_entry_dict())


func get_all() -> Array[MissingTableORMEntry]:
	var result: Array[MissingTableORMEntry] = []
	
	var query := "SELECT * FROM %s" % get_name()
	var query_result: Array[Dictionary] = DB._run_query_and_get_result_array(query)
	
	if query_result.is_empty():
		return []
	
	if query_result[0].has("error"):
		push_error("Error while getting all entries. Returning empty array. Error message: %s" % query_result[0]["error"])
		return []
	
	for result_dict in query_result:
		result.push_back(MissingTableORMEntry.wrap_query_result(result_dict))
	
	return result


func get_by_id(id: int) -> MissingTableORMEntry:
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
	
	return MissingTableORMEntry.wrap_query_result(query_result[0])


func update_by_id(id: int, updated_row: MissingTableORMEntry) -> bool:
	if updated_row == null:
		push_error("Cannot run update query when updated row is null")
		return false
	
	return DB._get_db().update_rows(
			get_name(),
			"%s.%s = %s" % [get_name(), self.id.name, id],
			updated_row.get_entry_dict()
		)



func _get_all_columns() -> Array[ORMColumn]:
	return [test, missing_column, id, ]
