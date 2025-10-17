class_name TestTableORM extends "res://common/scrpts/tables/test_table.gd"

#TODO Add entry value validation. That is, let entry pass value inside of it to
# column class, for it to validate, if it's correct


class TestTableORMSelect:
	extends ORMSelect
	
	
	func _init(table: ORMTable) -> void:
		super._init(table)
	
	
	func get_entries() -> Array[TestTableORMEntry]:
		if not _columns_to_query.is_empty():
			push_error("Cannot set custom select_columns while using get_entries() and get_first_entry(). Use get_as_raw_result() instead")
			return []
		
		var raw_results := get_as_raw_result()
		var entries: Array[TestTableORMEntry] = []
		for result in raw_results:
			entries.push_back(TestTableORMEntry.wrap_query_result(result))
		return entries
	
	
	func get_first_entry() -> TestTableORMEntry:
		_limit = 1
		var entries := get_entries()
		
		return entries[0] if not entries.is_empty() else null
	
	
	#region Recasting base methods
	
	func where(condition: ORMCondition) -> TestTableORMSelect:
		super.where(condition)
		return self
	
	
	func order_by_asc(column: ORMColumn) -> TestTableORMSelect:
		super.order_by_asc(column)
		return self
	
	
	func order_by_desc(column: ORMColumn) -> TestTableORMSelect:
		super.order_by_desc(column)
		return self
	
	
	func limit(amount: int, offset: int = 0) -> TestTableORMSelect:
		super.limit(amount, offset)
		return self
	
	
	func select_columns(columns: Array[ORMColumn]) -> TestTableORMSelect:
		super.select_columns(columns)
		return self
	
	
	func distinct(value: bool = true) -> TestTableORMSelect:
		super.distinct(value)
		return self
	
	#endregion


class TestTableORMUpdate:
	extends ORMUpdate
	
	
	func _init(table: ORMTable) -> void:
		super._init(table)
	
	
	#region Recasting base methods
	
	func set_updated_row(updated_row: ORMEntry) -> TestTableORMUpdate:
		super.set_updated_row(updated_row)
		return self
	
	func where(condition: ORMCondition) -> TestTableORMUpdate:
		super.where(condition)
		return self
	
	
	func order_by_asc(column: ORMColumn) -> TestTableORMUpdate:
		super.order_by_asc(column)
		return self
	
	
	func order_by_desc(column: ORMColumn) -> TestTableORMUpdate:
		super.order_by_desc(column)
		return self
	
	
	func limit(amount: int, offset: int = 0) -> TestTableORMUpdate:
		super.limit(amount, offset)
		return self
	
	
	func select_columns(columns: Array[ORMColumn]) -> TestTableORMUpdate:
		super.select_columns(columns)
		return self
	
	#endregion


func _init() -> void:
	_name = "test_table"
	
	number.name = 'number'
	text.name = 'text'
	real.name = 'real'
	
	
	super._init()


func create_select_query() -> TestTableORMSelect:
	return TestTableORMSelect.new(self)


func create_update_query() -> TestTableORMUpdate:
	return TestTableORMUpdate.new(self)


func create_delete_query() -> ORMDelete:
	return ORMDelete.new(self)


func put_entries_array_into_table(entries: Array[TestTableORMEntry]) -> void:
	DB._get_db().insert_rows(get_name(), entries.map(func(e: TestTableORMEntry): return e.get_entry_dict()) as Array[Dictionary])


func put_entry_into_table(entry: TestTableORMEntry) -> void:
	DB._get_db().insert_row(get_name(), entry.get_entry_dict())


func get_all() -> Array[TestTableORMEntry]:
	var result: Array[TestTableORMEntry] = []
	
	var query := "SELECT * FROM %s" % get_name()
	var query_result: Array[Dictionary] = DB._run_query_and_get_result_array(query)
	
	if query_result.is_empty():
		return []
	
	if query_result[0].has("error"):
		push_error("Error while getting all entries. Returning empty array. Error message: %s" % query_result[0]["error"])
		return []
	
	for result_dict in query_result:
		result.push_back(TestTableORMEntry.wrap_query_result(result_dict))
	
	return result





func _get_all_columns() -> Array[ORMColumn]:
	return [number, text, real, ]
