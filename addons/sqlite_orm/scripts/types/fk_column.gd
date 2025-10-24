class_name ORMForeignKeyColumn extends ORMIntColumn

var _reference_id_column: ORMPrimaryKeyColumn


func _init(references: ORMPrimaryKeyColumn, not_null: bool, unique: bool, use_default: bool, default: int = 0) -> void:
	_reference_id_column = references
	_not_null = not_null
	_unique = unique
	_use_default = use_default
	_default = default


func get_column_dict() -> Dictionary:
	var current := super.get_column_dict()
	
	assert(_reference_id_column != null, "Referened column id is null")
	assert(_reference_id_column.get_table() != get_table(), "Reference to the same table")
	
	current["foreign_key"] = _reference_id_column.get_name_with_table()
	
	return current
