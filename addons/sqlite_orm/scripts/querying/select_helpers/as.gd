class_name ORMSelectAs extends ORMSelectHelperBase

var _alias: String


func _init(column: Variant, alias: String) -> void:
	super._init(column)
	_alias = alias


func get_selection_string() -> String:
	return "%s AS '%s'" % [_column, _alias]
