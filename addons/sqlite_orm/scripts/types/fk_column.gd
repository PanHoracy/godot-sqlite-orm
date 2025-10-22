class_name ORMForeignKeyColumn extends ORMIntColumn

var _reference_id_column: ORMPkColumn


func _init(references: ORMPkColumn) -> void:
	_reference_id_column = references


func get_column_dict() -> Dictionary:
	var current := super.get_column_dict()
	
	assert(_reference_id_column != null, "Referened column id is null")
	assert(_reference_id_column.get_table() == get_table(), "Reference to the same table")
	
	current["foreign_key"] = _reference_id_column.get_name_with_table()
	
	return current
