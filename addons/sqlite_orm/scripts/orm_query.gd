class_name ORMQuery extends Node

#TODO Add description to functions
#TODO Add option to get data
#TODO Add option to update data
#TODO Add option to delete data
#TODO Add support for subquery in WHERE and operators that uses that
#TODO Add support for DISTINCT clause

enum Actions {
	UNSET,
	SELECT,
	SELECT_DISTINCT,
	UPDATE,
	DELETE
}

enum Orders {
	ASC,
	DESC
}

class OrderingEntry:
	extends RefCounted
	
	var column_name: String
	var order: Orders
	
	func _init(column_name: String, order: Orders) -> void:
		self.column_name = column_name
		self.order = order

var _table: Table = null
var _action: Actions = Actions.UNSET
var _condition: ORMCondition = null
var _ordering: Array[OrderingEntry] = []
var _columns_to_query: Array[String] = []
var _limit := -1
var _limit_offset := 0


func _init(table: Table) -> void:
	_table = table


func get_as_raw_result() -> Array[Dictionary]:
	_action = Actions.SELECT
	return _run_query()


func get_distinct_as_raw_result() -> Array[Dictionary]:
	_action = Actions.SELECT_DISTINCT
	return _run_query()


func where(condition: ORMCondition) -> ORMQuery:
	_condition = condition
	return self


func order_by_asc(column: Column) -> ORMQuery:
	_ordering.push_back(OrderingEntry.new(column.get_name_with_table(), Orders.ASC))
	return self


func order_by_desc(column: Column) -> ORMQuery:
	_ordering.push_back(OrderingEntry.new(column.get_name_with_table(), Orders.DESC))
	return self


func clear_ordering() -> void:
	_ordering = []


func select_columns(columns: Array[Column]) -> ORMQuery:
	_columns_to_query = Array(columns.map(func(c: Column): return c.get_name_with_table()), TYPE_STRING, "", null)
	return self


func clear_selected_columns() -> ORMQuery:
	_columns_to_query = []
	return self


func limit(amount: int, offset: int = 0) -> ORMQuery:
	if amount < 0 or offset < 0:
		push_error("Limit and offset cannot be a negative number, aborting")
		return self
	
	_limit = amount
	_limit_offset = offset
	
	return self


func _run_query() -> Array[Dictionary]:
	if _table == null:
		push_error("Cannot run query without table provided. Aborting query")
		return []
	
	if _action == Actions.UNSET:
		push_error("Action to perform was not selected. Aborting query")
		return []
	
	var pattern := ""
	match _action:
		Actions.SELECT:
			pattern = "SELECT %s FROM %s"
		Actions.SELECT_DISTINCT:
			pattern = "SELECT DISTINCT %s FROM %s"
		_:
			print("Action not supported yet")
	
	var columns_to_query_string := ""
	if not _columns_to_query.is_empty():
		for column_name in _columns_to_query:
			columns_to_query_string += column_name + ", "
		columns_to_query_string = columns_to_query_string.substr(0, len(columns_to_query_string)-2)
	else:
		columns_to_query_string = "*"
	
	var query := pattern % [columns_to_query_string, _table.get_name()]
	if _condition != null:
		query += "\n WHERE %s" % _condition.get_condition()
	if not _ordering.is_empty():
		var order := ""
		for order_entry in _ordering:
			order += "%s %s, " % [order_entry.column_name, "ASC" if order_entry.order == Orders.ASC else "DESC"]
		order = order.substr(0, len(order)-2)
		query += "\n ORDER BY %s" % order
	if _limit > 0:
		query += "\n LIMIT %s OFFSET %s" % [_limit, _limit_offset]
	
	print("Entered query: %s" % query)
	return DB._run_query_and_get_result_array(query)
