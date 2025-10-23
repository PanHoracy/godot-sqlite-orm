class_name ORMIntColumn extends ORMColumn

var _use_default: bool = false
var _default: int = 0


func _init(not_null: bool, unique: bool, use_default: bool, default: int = 0) -> void:
	_not_null = not_null
	_unique = unique
	_use_default = use_default
	_default = default


func get_column_dict() -> Dictionary:
	var current := super.get_column_dict()
	
	current["data_type"] = "int"
	if _use_default:
		current["default"] = _default
	
	return current
