class_name ORMFloatColumn extends ORMColumn

var use_default: bool = false
var default: float = 0.0


func set_default(value: float) -> ORMFloatColumn:
	use_default = true
	default = value
	return self


func set_not_null(value: bool = true) -> ORMFloatColumn:
	return super.set_not_null(value)


func set_unique(value: bool = true) -> ORMFloatColumn:
	return super.set_unique(value)


func get_column_dict() -> Dictionary:
	var current := super.get_column_dict()
	
	current["data_type"] = "real"
	if use_default:
		current["default"] = default
	
	return current
