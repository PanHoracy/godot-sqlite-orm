class_name ProductTableORM extends "res://common/scrpts/tables/product_table.gd"

#TODO Add entry value validation. That is, let entry pass value inside of it to
# column class, for it to validate, if it's correct


class ProductTableORMSelect:
	extends ORMSelect
	
	
	func _init(table: ORMTable) -> void:
		super._init(table)
	
	
	func get_entries() -> Array[ProductTableORMEntry]:
		var raw_results := get_as_raw_result()
		var entries: Array[ProductTableORMEntry] = []
		for result in raw_results:
			entries.push_back(ProductTableORMEntry.wrap_query_result(result))
		return entries
	
	
	func get_first_entry() -> ProductTableORMEntry:
		_limit = 1
		var entries := get_entries()
		
		return entries[0] if not entries.is_empty() else null
	
	
	#region Recasting base methods
	
	func where(condition: ORMCondition) -> ProductTableORMSelect:
		return super.where(condition) as ProductTableORMSelect
	
	
	func order_by_asc(column: ORMColumn) -> ProductTableORMSelect:
		return super.order_by_asc(column) as ProductTableORMSelect
	
	
	func order_by_desc(column: ORMColumn) -> ProductTableORMSelect:
		return super.order_by_desc(column) as ProductTableORMSelect
	
	
	func limit(amount: int, offset: int = 0) -> ProductTableORMSelect:
		return super.limit(amount, offset) as ProductTableORMSelect
	
	
	func select_columns(columns: Array[ORMColumn]) -> ProductTableORMSelect:
		return super.select_columns(columns) as ProductTableORMSelect
	
	
	func distinct(value: bool = true) -> ProductTableORMSelect:
		return super.distinct(value) as ProductTableORMSelect
	
	#endregion


class ProductTableORMUpdate:
	extends ORMQuery
	
	var _updated_row: ProductTableORMEntry = null
	
	
	func _init(table: ORMTable) -> void:
		super._init(table)
	
	
	func set_row(updated_row: ProductTableORMEntry) -> ProductTableORMUpdate:
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
	
	func where(condition: ORMCondition) -> ProductTableORMUpdate:
		return super.where(condition) as ProductTableORMUpdate
	
	
	func order_by_asc(column: ORMColumn) -> ProductTableORMUpdate:
		return super.order_by_asc(column) as ProductTableORMUpdate
	
	
	func order_by_desc(column: ORMColumn) -> ProductTableORMUpdate:
		return super.order_by_desc(column) as ProductTableORMUpdate
	
	
	func limit(amount: int, offset: int = 0) -> ProductTableORMUpdate:
		return super.limit(amount, offset) as ProductTableORMUpdate
	
	#endregion


func _init() -> void:
	_name = "product_table"
	
	product_name.name = 'product_name'
	price.name = 'price'
	id.name = 'id'
	
	
	super._init()


func create_select_query() -> ProductTableORMSelect:
	return ProductTableORMSelect.new(self)


func create_update_query() -> ProductTableORMUpdate:
	return ProductTableORMUpdate.new(self)


func put_entries_array_into_table(entries: Array[ProductTableORMEntry]) -> void:
	DB._get_db().insert_rows(get_name(), entries.map(func(e: ProductTableORMEntry): return e.get_entry_dict()) as Array[Dictionary])


func put_entry_into_table(entry: ProductTableORMEntry) -> void:
	DB._get_db().insert_row(get_name(), entry.get_entry_dict())


func get_all() -> Array[ProductTableORMEntry]:
	var result: Array[ProductTableORMEntry] = []
	
	var query := "SELECT * FROM %s" % get_name()
	var query_result: Array[Dictionary] = DB._run_query_and_get_result_array(query)
	
	if query_result.is_empty():
		return []
	
	if query_result[0].has("error"):
		push_error("Error while getting all entries. Returning empty array. Error message: %s" % query_result[0]["error"])
		return []
	
	for result_dict in query_result:
		result.push_back(ProductTableORMEntry.wrap_query_result(result_dict))
	
	return result


func get_by_id(id: int) -> ProductTableORMEntry:
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
	
	return ProductTableORMEntry.wrap_query_result(query_result[0])


func update_by_id(id: int, updated_row: ProductTableORMEntry) -> bool:
	if updated_row == null:
		push_error("Cannot run update query when updated row is null")
		return false
	
	return DB._get_db().update_rows(
			get_name(),
			"%s.%s = %s" % [get_name(), self.id.name, id],
			updated_row.get_entry_dict()
		)



func _get_all_columns() -> Array[ORMColumn]:
	return [product_name, price, id, ]
