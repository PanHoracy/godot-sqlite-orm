@abstract
class_name ORMColumnBuilder extends RefCounted

var _not_null: bool = false
var _unique: bool = false


func set_not_null(value: bool = true) -> ORMColumnBuilder:
	_not_null = value
	return self


func set_unique(value: bool = true) -> ORMColumnBuilder:
	_unique = value
	return self


@abstract
func build() -> ORMColumn
