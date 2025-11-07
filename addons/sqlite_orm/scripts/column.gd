@abstract
class_name ORMColumn extends ORMConditionElement

#TODO Add aggregate function quick querys

var name: String = ""
var _not_null: bool = false
var _unique: bool = false

var _table: ORMTable = null


func get_column_dict() -> Dictionary:
	return {"not_null": _not_null, "unique": _unique}


func get_table() -> ORMTable:
	return _table


func get_name_with_table() -> String:
	return "%s.%s" % [get_table().get_name(), name]


func _set_table(table: ORMTable) -> void:
	_table = table


func _get_left_side() -> String:
	return get_name_with_table()
