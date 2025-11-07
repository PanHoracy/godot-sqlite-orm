class_name ORMSelectCount extends ORMSelectHelperBase


func get_selection_string() -> String:
	return "COUNT(%s)" % _column
