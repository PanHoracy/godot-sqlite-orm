class_name IntColumn extends Column

#TODO Add class and members description

var use_default: bool = false
var default: int = 0

var foregin_key: Table = null


func set_default(value: int) -> IntColumn:
	use_default = true
	default = value
	return self


func set_foregin_key(value: Table) -> IntColumn:
	foregin_key = value
	return self


func set_not_null(value: bool = true) -> IntColumn:
	return super.set_not_null(value)


func set_unique(value: bool = true) -> IntColumn:
	return super.set_unique(value)


func get_column_dict() -> Dictionary:
	var current := super.get_column_dict()
	
	current["data_type"] = "int"
	if use_default:
		current["default"] = default
	if foregin_key != null:
		current["foreign_key"] = foregin_key.name + ".id"
	
	return current
