class_name ORMPrimaryKeyColumn extends ORMIntColumn

func _init() -> void:
	_not_null = true
	_unique = true


func get_column_dict() -> Dictionary:
	var current := super.get_column_dict()
	
	current["primary_key"] = true
	current["auto_increment"] = true

	return current
