class_name ORMSelectSum extends ORMSelectHelperBase


func get_selection_string() -> String:
	return "SUM(%s)" % _column
