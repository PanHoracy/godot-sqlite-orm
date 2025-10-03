class_name Table extends RefCounted

#TODO Rename to ORMTable

var _name: String = ""


func _init() -> void:
	for column in _get_all_columns():
		column._table = self


func _to_string() -> String:
	return "<Table: %s>" % _name


func get_name() -> String:
	return _name


func get_table_dict() -> Dictionary:
	var dict := {}
	
	for column in _get_all_columns():
		dict[column.name] = column.get_column_dict()
	
	return dict


func _get_all_columns() -> Array[Column]:
	return []
