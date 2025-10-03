class_name Column extends RefCounted

#TODO Rename to ORMColumn
#TODO Add class and members description

enum SQLTypes {
	INTEGER,
	REAL,
	TEXT,
	BLOB,
	UNDEFINED
}

var name: String = ""
var not_null: bool = false
var unique: bool = false

var _table: Table = null


func set_not_null(value: bool = true) -> Column:
	not_null = value
	return self


func set_unique(value: bool = true) -> Column:
	unique = value
	return self


func get_column_dict() -> Dictionary:
	return {"not_null": not_null, "unique": unique}


func get_table() -> Table:
	return _table


func get_name_with_table() -> String:
	return "%s.%s" % [get_table().get_name(), name]

#FIXME Double of get_name_with_table()
func get_as_condition_string() -> String:
	return "%s.%s" % [get_table().get_name(), name]


#region: Condition helpers


func _get_value_as_right_string(value) -> String:
	var right := ""
	
	if value is Column:
		right = "%s.%s" % [value.get_table().get_name(), value.name]
	elif value is String:
		right = "'%s'" % value
	else:
		right = str(value)
	
	return right


func _fill_operator(condition: String, value) -> String:
	var left := get_name_with_table()
	var right := _get_value_as_right_string(value)
	
	return condition % [left, right]


func equal(value) -> ORMCondition:
	return ORMCondition.new(_fill_operator("%s = %s", value))


func not_equal(value) -> ORMCondition:
	return ORMCondition.new(_fill_operator("%s != %s", value))


func less_then(value) -> ORMCondition:
	return ORMCondition.new(_fill_operator("%s < %s", value))


func grether_than(value) -> ORMCondition:
	return ORMCondition.new(_fill_operator("%s > %s", value))


func less_or_equal_then(value) -> ORMCondition:
	return ORMCondition.new(_fill_operator("%s <= %s", value))


func grether_or_equal_then(value) -> ORMCondition:
	return ORMCondition.new(_fill_operator("%s >= %s", value))


func is_null() -> ORMCondition:
	return ORMCondition.new("%s IS NULL" % get_name_with_table())


func is_not_null() -> ORMCondition:
	return ORMCondition.new("%s IS NOT NULL" % get_name_with_table())


func not_between(low, high) -> ORMCondition:
	return between(low, high, true)


func between(low, high, inverse: bool = false) -> ORMCondition:
	var test := "%s.%s" % [get_table().get_name(), name]
	var low_string := _get_value_as_right_string(low)
	var high_string := _get_value_as_right_string(high)
	
	var pattern := "%s BETWEEN %s AND %s" if not inverse else "%s NOT BETWEEN %s AND %s"
	
	return ORMCondition.new(pattern % [test, low_string, high_string])


func value_not_in(array: Array) -> ORMCondition:
	return value_in(array, true)


func value_in(array: Array, inverse: bool = false) -> ORMCondition:
	var test := "%s.%s" % [get_table().get_name(), name]
	var condition := ("%s IN (" % test) if not inverse else ("%s NOT IN (" % test)
	for element in array:
		condition += _get_value_as_right_string(element) + ", "
	condition = condition.substr(0, len(condition)-2)
	condition += ")"
	return ORMCondition.new(condition)

#endregion
