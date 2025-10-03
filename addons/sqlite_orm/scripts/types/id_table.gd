class_name IdTable extends Table

var id := PkColumn.new()


func _init() -> void:
	id.name = "id"


func _get_all_columns() -> Array[Column]:
	var result: Array[Column] = [id]
	
	result.append_array(super._get_all_columns())
	
	return result 
