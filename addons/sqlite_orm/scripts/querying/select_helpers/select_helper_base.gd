@abstract
class_name ORMSelectHelperBase extends ORMConditionElement

var _column: String
var _from_table: String


func _init(column: Variant) -> void:
	if column is ORMColumn:
		_column = column.get_name_with_table()
		_from_table = column.get_table().get_name()
	elif column is ORMSelectHelperBase:
		_column = column.get_selection_string()
		_from_table = column.get_from_table()
	else:
		push_error("Passed invalid value")


@abstract func get_selection_string() -> String


func _get_left_side() -> String:
	return get_selection_string()


func get_from_table() -> String:
	return _from_table
