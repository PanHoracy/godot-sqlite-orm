class_name ORMSelectMin extends ORMSelectHelperBase


func get_selection_string() -> String:
	return "MIN(%s)" % _column
