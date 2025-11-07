class_name ORMSelectAvg extends ORMSelectHelperBase


func get_selection_string() -> String:
	return "AVG(%s)" % _column
