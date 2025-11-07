class_name TestTableORM extends "res://common/scrpts/tables/test_table.gd"

#TODO Add entry value validation. That is, let entry pass value inside of it to
# column class, for it to validate, if it's correct


class TestTableORMSelect:
	extends ORMSelect
	
	var _parent_table: TestTableORM
	
	
	func _init(parent_table: TestTableORM) -> void:
		_parent_table = parent_table
	
	
	func _get_from_table() -> String:
		return _parent_table.get_name()
	
	
	func _get_selected() -> String:
		return ", ".join(_parent_table.get_all_columns().map(func(c: ORMColumn): return c.get_name_with_table()))
	
	
	func _get_join_clauses() -> String:
		return ""
	
	
	func get_entries() -> Array[TestTableORMEntry]:
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
	
	func group_by(...columns: Array) -> TestTableORMSelect:
		super.group_by(columns)
		return self
	
	
	func having(condition: ORMCondition) -> TestTableORMSelect:
		super.having(condition)
		return self
	
	
	func distinct(value: bool = true) -> TestTableORMSelect:
		super.distinct(value)
		return self
	
	
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
	
	#endregion


func _init() -> void:
	_name = "test_table"
	
	number.name = 'number'
	text.name = 'text'
	real.name = 'real'
	
	
	super._init()


func create_select_query() -> TestTableORMSelect:
	return TestTableORMSelect.new(self)


func create_update_query() -> ORMUpdate:
	return ORMUpdate.new(self)


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





func get_all_columns() -> Array[ORMColumn]:
	return [number, text, real, ]
