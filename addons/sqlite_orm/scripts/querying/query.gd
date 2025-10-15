@abstract
class_name ORMQuery extends Node

var _table: ORMTable = null
var _condition: ORMCondition = null


func _init(table: ORMTable) -> void:
	_table = table


func where(condition: ORMCondition) -> ORMQuery:
	_condition = condition
	return self
