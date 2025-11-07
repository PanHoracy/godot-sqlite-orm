class_name ORMIdTable extends ORMTable

var id := ORMPrimaryKeyColumn.new()


func _init() -> void:
	id.name = "id"
	
	super._init()


func get_all_columns() -> Array[ORMColumn]:
	var result: Array[ORMColumn] = [id]
	
	result.append_array(super.get_all_columns())
	
	return result 
