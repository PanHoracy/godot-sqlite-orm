class_name ORMAggregateFunction extends ORMConditionElement

var _column: String
var _from_table: String
var _pattern: String
var _args: Array


func _init(pattern: String, column: Variant = null, ...args: Array) -> void:
	_pattern = pattern
	
	if column is ORMColumn:
		_column = column.get_name_with_table()
		_from_table = column.get_table().get_name()
	elif column is ORMAggregateFunction:
		_column = column.get_selection_string()
		_from_table = column.get_from_table()
	elif column == null:
		_column = ""
		_from_table = ""
	else:
		push_error("Passed invalid value")
	
	_args = args
	_args.push_back(["column", _column])


func get_selection_string() -> String:
	return _pattern.format(_args)


func _get_left_side() -> String:
	return get_selection_string()


func get_from_table() -> String:
	return _from_table
