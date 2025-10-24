class_name ORMStringColumnBuilder extends ORMColumnBuilder

var _use_default: bool = false
var _default: String = ""


func set_default(value: String) -> ORMStringColumnBuilder:
	_use_default = true
	_default = "'%s'" % value
	return self


func set_not_null(value: bool = true) -> ORMStringColumnBuilder:
	return super.set_not_null(value)


func set_unique(value: bool = true) -> ORMStringColumnBuilder:
	return super.set_unique(value)


func build() -> ORMStringColumn:
	return ORMStringColumn.new(_not_null, _unique, _use_default, _default)
