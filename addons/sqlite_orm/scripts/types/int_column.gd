class_name ORMIntColumn extends ORMColumn

var use_default: bool = false
var default: int = 0

var foregin_key: ORMTable = null


func set_default(value: int) -> ORMIntColumn:
	use_default = true
	default = value
	return self


func set_foregin_key(value: ORMTable) -> ORMIntColumn:
	foregin_key = value
	return self


func set_not_null(value: bool = true) -> ORMIntColumn:
	return super.set_not_null(value)


func set_unique(value: bool = true) -> ORMIntColumn:
	return super.set_unique(value)


func get_column_dict() -> Dictionary:
	var current := super.get_column_dict()
	
	current["data_type"] = "int"
	if use_default:
		current["default"] = default
	if foregin_key != null:
		current["foreign_key"] = foregin_key.name + ".id"
	
	return current
