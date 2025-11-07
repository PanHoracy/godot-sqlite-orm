class_name ORMStringColumn extends ORMColumn

var _use_default: bool = false
var _default: String = ""


func _init(not_null: bool, unique: bool, use_default: bool, default: String = "") -> void:
	_not_null = not_null
	_unique = unique
	_use_default = use_default
	_default = default


func get_column_dict() -> Dictionary:
	var current := super.get_column_dict()
	
	current["data_type"] = "text"
	if _use_default:
		current["default"] = _default
	
	return current


func get_all_values(distinct: bool = false) -> Array[String]:
	return Array(super.get_all_values(distinct), TYPE_STRING, "", null)


func get_max(distinct: bool = false) -> String:
	return str(super.get_max(distinct))


func get_min(distinct: bool = false) -> String:
	return str(super.get_min(distinct))


#region Condition helpers

func not_like(pattern: String) -> ORMCondition:
	var left := "%s.%s" % [get_table().get_name(), name]
	return ORMCondition.new("%s NOT LIKE '%s'" % [left, pattern])


func like(pattern: String) -> ORMCondition:
	var left := "%s.%s" % [get_table().get_name(), name]
	return ORMCondition.new("%s LIKE '%s'" % [left, pattern])


func not_glob(pattern: String) -> ORMCondition:
	var left := "%s.%s" % [get_table().get_name(), name]
	return ORMCondition.new("%s NOT GLOB '%s'" % [left, pattern])


func glob(pattern: String) -> ORMCondition:
	var left := "%s.%s" % [get_table().get_name(), name]
	return ORMCondition.new("%s GLOB '%s'" % [left, pattern])

#endregion
