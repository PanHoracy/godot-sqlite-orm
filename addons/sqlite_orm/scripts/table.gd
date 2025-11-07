@abstract
class_name ORMTable extends RefCounted

var _name: String = ""


func _init() -> void:
	for column in get_all_columns():
		column._set_table(self)


func _to_string() -> String:
	return "<ORMTable: %s>" % _name


func get_name() -> String:
	return _name


func get_table_dict() -> Dictionary:
	var dict := {}
	
	for column in get_all_columns():
		dict[column.name] = column.get_column_dict()
	
	return dict


func get_row_count() -> int:
	var query := "SELECT COUNT(*) AS RES FROM %s" % get_name()
	
	var result := DB._run_query_and_get_result_array(query)
	
	return result[0]["RES"]


func get_all_columns() -> Array[ORMColumn]:
	return []
