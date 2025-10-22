class_name ProducerTableORM extends "res://common/scrpts/tables/producer_table.gd"

#TODO Add entry value validation. That is, let entry pass value inside of it to
# column class, for it to validate, if it's correct


class ProducerTableORMSelect:
	extends ORMSelect
	
	
	func _init(table: ORMTable) -> void:
		super._init(table)
	
	
	func get_entries() -> Array[ProducerTableORMEntry]:
		if not _columns_to_query.is_empty():
			push_error("Cannot set custom select_columns while using get_entries() and get_first_entry(). Use get_as_raw_result() instead")
			return []
		
		var raw_results := get_as_raw_result()
		var entries: Array[ProducerTableORMEntry] = []
		for result in raw_results:
			entries.push_back(ProducerTableORMEntry.wrap_query_result(result))
		return entries
	
	
	func get_first_entry() -> ProducerTableORMEntry:
		_limit = 1
		var entries := get_entries()
		
		return entries[0] if not entries.is_empty() else null
	
	
	#region Recasting base methods
	
	func where(condition: ORMCondition) -> ProducerTableORMSelect:
		super.where(condition)
		return self
	
	
	func order_by_asc(column: ORMColumn) -> ProducerTableORMSelect:
		super.order_by_asc(column)
		return self
	
	
	func order_by_desc(column: ORMColumn) -> ProducerTableORMSelect:
		super.order_by_desc(column)
		return self
	
	
	func limit(amount: int, offset: int = 0) -> ProducerTableORMSelect:
		super.limit(amount, offset)
		return self
	
	
	func select_columns(columns: Array[ORMColumn]) -> ProducerTableORMSelect:
		super.select_columns(columns)
		return self
	
	
	func distinct(value: bool = true) -> ProducerTableORMSelect:
		super.distinct(value)
		return self
	
	#endregion


class ProducerTableORMUpdate:
	extends ORMUpdate
	
	
	func _init(table: ORMTable) -> void:
		super._init(table)
	
	
	#region Recasting base methods
	
	func set_updated_row(updated_row: ORMEntry) -> ProducerTableORMUpdate:
		super.set_updated_row(updated_row)
		return self
	
	func where(condition: ORMCondition) -> ProducerTableORMUpdate:
		super.where(condition)
		return self
	
	
	func order_by_asc(column: ORMColumn) -> ProducerTableORMUpdate:
		super.order_by_asc(column)
		return self
	
	
	func order_by_desc(column: ORMColumn) -> ProducerTableORMUpdate:
		super.order_by_desc(column)
		return self
	
	
	func limit(amount: int, offset: int = 0) -> ProducerTableORMUpdate:
		super.limit(amount, offset)
		return self
	
	
	func select_columns(columns: Array[ORMColumn]) -> ProducerTableORMUpdate:
		super.select_columns(columns)
		return self
	
	#endregion


func _init() -> void:
	_name = "producer_table"
	
	producer_name.name = 'producer_name'
	id.name = 'id'
	
	
	super._init()


func create_select_query() -> ProducerTableORMSelect:
	return ProducerTableORMSelect.new(self)


func create_update_query() -> ProducerTableORMUpdate:
	return ProducerTableORMUpdate.new(self)


func create_delete_query() -> ORMDelete:
	return ORMDelete.new(self)


func put_entries_array_into_table(entries: Array[ProducerTableORMEntry]) -> void:
	DB._get_db().insert_rows(get_name(), entries.map(func(e: ProducerTableORMEntry): return e.get_entry_dict()) as Array[Dictionary])


func put_entry_into_table(entry: ProducerTableORMEntry) -> void:
	DB._get_db().insert_row(get_name(), entry.get_entry_dict())


func get_all() -> Array[ProducerTableORMEntry]:
	var result: Array[ProducerTableORMEntry] = []
	
	var query := "SELECT * FROM %s" % get_name()
	var query_result: Array[Dictionary] = DB._run_query_and_get_result_array(query)
	
	if query_result.is_empty():
		return []
	
	if query_result[0].has("error"):
		push_error("Error while getting all entries. Returning empty array. Error message: %s" % query_result[0]["error"])
		return []
	
	for result_dict in query_result:
		result.push_back(ProducerTableORMEntry.wrap_query_result(result_dict))
	
	return result


func get_by_id(id: int) -> ProducerTableORMEntry:
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
	
	return ProducerTableORMEntry.wrap_query_result(query_result[0])


func update_by_id(id: int, updated_row: ProducerTableORMEntry) -> bool:
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



func _get_all_columns() -> Array[ORMColumn]:
	return [producer_name, id, ]
