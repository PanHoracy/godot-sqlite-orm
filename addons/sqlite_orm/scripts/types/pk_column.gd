class_name ORMPkColumn extends ORMIntColumn

func _init() -> void:
	not_null = true
	unique = true


func get_column_dict() -> Dictionary:
	var current := super.get_column_dict()
	
	current["primary_key"] = true
	current["auto_increment"] = true

	return current
