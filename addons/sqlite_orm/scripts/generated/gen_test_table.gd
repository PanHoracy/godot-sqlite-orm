class_name TestTableORM extends "res://common/scrpts/tables/test_table.gd"

#TODO Add entry value validation. That is, let entry pass value inside of it to
# column class, for it to validate, if it's correct


class TestTableORMSelect:
	extends ORMSelect
	
	
	func _init(table: ORMTable) -> void:
		super._init(table)
	
	
	func get_entries() -> Array[TestTableORMEntry]:
		var raw_results := get_as_raw_result()
		var entries: Array[TestTableORMEntry] = []
		for result in raw_results:
			entries.push_back(TestTableORMEntry.wrap_query_result(result))
		return entries
	
	
	func where(condition: ORMCondition) -> TestTableORMSelect:
		return super.where(condition) as TestTableORMSelect
	
	
	func order_by_asc(column: ORMColumn) -> TestTableORMSelect:
		return super.order_by_asc(column) as TestTableORMSelect
	
	
	func order_by_desc(column: ORMColumn) -> TestTableORMSelect:
		return super.order_by_desc(column) as TestTableORMSelect
	
	
	func limit(amount: int, offset: int = 0) -> TestTableORMSelect:
		return super.limit(amount, offset) as TestTableORMSelect
	
	
	func select_columns(columns: Array[ORMColumn]) -> TestTableORMSelect:
		return super.select_columns(columns) as TestTableORMSelect
	
	
	func distinct(value: bool = true) -> TestTableORMSelect:
		return super.distinct(value) as TestTableORMSelect


func _init() -> void:
	_name = "test_table"
	
	number.name = 'number'
	text.name = 'text'
	real.name = 'real'
	
	
	super._init()


func create_select_query() -> TestTableORMSelect:
	return TestTableORMSelect.new(self)


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
