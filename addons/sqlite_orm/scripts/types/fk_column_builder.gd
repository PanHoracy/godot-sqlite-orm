class_name ORMForeignKeyColumnBuilder extends ORMColumnBuilder

var _use_default: bool = false
var _default: int = 0
var _reference: ORMPrimaryKeyColumn


func _init(reference: ORMPrimaryKeyColumn) -> void:
	_reference = reference


func set_default(value: int) -> ORMForeignKeyColumnBuilder:
	_use_default = true
	_default = value
	return self


func set_not_null(value: bool = true) -> ORMForeignKeyColumnBuilder:
	return super.set_not_null(value)


func set_unique(value: bool = true) -> ORMForeignKeyColumnBuilder:
	return super.set_unique(value)


func build() -> ORMForeignKeyColumn:
	return ORMForeignKeyColumn.new(_reference, _not_null, _unique, _use_default, _default)
