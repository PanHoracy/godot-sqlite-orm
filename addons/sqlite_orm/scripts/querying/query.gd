@abstract
class_name ORMQuery extends Node

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

var _table: ORMTable = null
var _condition: ORMCondition = null
var _ordering: Array[OrderingEntry] = []
var _limit := -1
var _limit_offset := 0


func _init(table: ORMTable) -> void:
	_table = table


func where(condition: ORMCondition) -> ORMQuery:
	_condition = condition
	return self


func order_by_asc(column: ORMColumn) -> ORMQuery:
	_ordering.push_back(OrderingEntry.new(column.get_name_with_table(), Orders.ASC))
	return self


func order_by_desc(column: ORMColumn) -> ORMQuery:
	_ordering.push_back(OrderingEntry.new(column.get_name_with_table(), Orders.DESC))
	return self


func clear_ordering() -> void:
	_ordering = []


func limit(amount: int, offset: int = 0) -> ORMQuery:
	if amount < 0 or offset < 0:
		push_error("Limit and offset cannot be a negative number, aborting")
		return self
	
	_limit = amount
	_limit_offset = offset
	
	return self


func _get_ordering() -> String:
	var order := ""
	for order_entry in _ordering:
		order += "%s %s, " % [order_entry.column_name, "ASC" if order_entry.order == Orders.ASC else "DESC"]
	order = order.substr(0, len(order)-2)
	return order
