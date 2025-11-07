@abstract
class_name ORMColumn extends ORMConditionElement

var name: String = ""
var _not_null: bool = false
var _unique: bool = false

var _table: ORMTable = null


func get_column_dict() -> Dictionary:
	return {"not_null": _not_null, "unique": _unique}


func get_table() -> ORMTable:
	return _table


func get_name_with_table() -> String:
	return "%s.%s" % [get_table().get_name(), name]


func get_all_values(distinct: bool = false) -> Array:
	var result: Array = []
	
	var query := "SELECT%s %s FROM %s" % [(" DISTINCT" if distinct else ""), get_name_with_table(), _table.get_name()]
	result = DB._run_query_and_get_result_array(query)
	
	return result.map(func(row: Dictionary): return row[name])


func get_average(distinct: bool = false) -> float:
	var query := "SELECT AVG(%s%s) AS RES FROM %s" % [("DISTINCT " if distinct else ""), get_name_with_table(), _table.get_name()]
	return DB._run_query_and_get_result_array(query)[0]["RES"]


func get_count(distinct: bool = false) -> int:
	var query := "SELECT COUNT(%s%s) AS RES FROM %s" % [("DISTINCT " if distinct else ""), get_name_with_table(), _table.get_name()]
	return DB._run_query_and_get_result_array(query)[0]["RES"]


func get_max(distinct: bool = false) -> Variant:
	var query := "SELECT MAX(%s%s) AS RES FROM %s" % [("DISTINCT " if distinct else ""), get_name_with_table(), _table.get_name()]
	return DB._run_query_and_get_result_array(query)[0]["RES"]


func get_min(distinct: bool = false) -> Variant:
	var query := "SELECT MIN(%s%s) AS RES FROM %s" % [("DISTINCT " if distinct else ""), get_name_with_table(), _table.get_name()]
	return DB._run_query_and_get_result_array(query)[0]["RES"]


func get_sum(distinct: bool = false) -> Variant:
	var query := "SELECT SUM(%s%s) AS RES FROM %s" % [("DISTINCT " if distinct else ""), get_name_with_table(), _table.get_name()]
	return DB._run_query_and_get_result_array(query)[0]["RES"]


func _set_table(table: ORMTable) -> void:
	_table = table


func _get_left_side() -> String:
	return get_name_with_table()
