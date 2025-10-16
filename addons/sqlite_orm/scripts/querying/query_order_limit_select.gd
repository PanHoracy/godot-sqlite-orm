@abstract
class_name ORMQueryWithLimitOrderSelect extends ORMQueryWithLimitOrder

var _columns_to_query: Array[String] = []


func _init(table: ORMTable) -> void:
	super._init(table)


func select_columns(columns: Array[ORMColumn]) -> ORMQueryWithLimitOrderSelect:
	_columns_to_query = Array(columns.map(func(c: ORMColumn): return c.get_name_with_table()), TYPE_STRING, "", null)
	return self


func clear_selected_columns() -> void:
	_columns_to_query = []
