class_name ORMSelectMax extends ORMSelectHelperBase


func get_selection_string() -> String:
	return "MAX(%s)" % _column
