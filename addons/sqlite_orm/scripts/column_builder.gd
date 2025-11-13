@abstract
class_name ORMColumnBuilder extends RefCounted

var _not_null: bool = false
var _unique: bool = false
var _old_names: Array[String] = []


func set_not_null(value: bool = true) -> ORMColumnBuilder:
	_not_null = value
	return self


func set_unique(value: bool = true) -> ORMColumnBuilder:
	_unique = value
	return self


func set_old_names(values: Array) -> ORMColumnBuilder:
	for value in values:
		if value is String:
			_old_names.push_back(value)
		else:
			push_error("Invalid data type in set_old_names (only Strings are accepted)")
	
	return self


@abstract
func build() -> ORMColumn
