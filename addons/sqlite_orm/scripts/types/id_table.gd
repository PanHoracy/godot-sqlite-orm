class_name ORMIdTable extends ORMTable

var id := ORMPkColumn.new()


func _init() -> void:
	id.name = "id"


func _get_all_columns() -> Array[ORMColumn]:
	var result: Array[ORMColumn] = [id]
	
	result.append_array(super._get_all_columns())
	
	return result 
