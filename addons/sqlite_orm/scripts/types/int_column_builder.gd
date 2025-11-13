class_name ORMIntColumnBuilder extends ORMColumnBuilder

var _use_default: bool = false
var _default: int = 0


func set_default(value: int) -> ORMIntColumnBuilder:
	_use_default = true
	_default = value
	return self


func set_not_null(value: bool = true) -> ORMIntColumnBuilder:
	return super.set_not_null(value)


func set_unique(value: bool = true) -> ORMIntColumnBuilder:
	return super.set_unique(value)


func set_old_names(...values: Array) -> ORMIntColumnBuilder:
	super.set_old_names(values)
	return self


func build() -> ORMIntColumn:
	var result := ORMIntColumn.new(_not_null, _unique, _use_default, _default)
	result._old_names = _old_names
	return result
