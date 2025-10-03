class_name ProductTableORM extends "res://common/scrpts/tables/product_table.gd"

#TODO Add entry value validation. That is, let entry pass value inside of it to
# column class, for it to validate, if it's correct

#TODO Add descriptions to exposed table methods

func _init() -> void:
	_name = "product_table"
	
	product_name.name = 'product_name'
	price.name = 'price'
	id.name = 'id'
	
	
	super._init()

#HACK Should have type specification. Currenty removed becasue getting class of
# a class nested in other class in autoload is not possible. 
func put_entries_array_into_table(entries: Array) -> void:
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



func _get_all_columns() -> Array[Column]:
	var result: Array[Column] = [product_name, price, id, ]
	
	result.append_array(super._get_all_columns())
	
	return result
