class_name StringColumn extends Column

var use_default: bool = false
var default: String = ""


func set_default(value: String) -> StringColumn:
	use_default = true
	default = value
	return self


func set_not_null(value: bool = true) -> StringColumn:
	return super.set_not_null(value)


func set_unique(value: bool = true) -> StringColumn:
	return super.set_unique(value)


func get_column_dict() -> Dictionary:
	var current := super.get_column_dict()
	
	current["data_type"] = "text"
	if use_default:
		current["default"] = default
	
	return current


#region: Condition helpers

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
