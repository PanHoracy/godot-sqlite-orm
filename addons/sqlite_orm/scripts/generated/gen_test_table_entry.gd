class_name TestTableORMEntry extends ORMEntry

const EXCLUDED_PROPERTIES: Array[String] = ["RefCounted", "script", "Built-in script", "_parent_table", "gen_test_table_entry.gd", "_fields", "orm_entry.gd"]

var number: int
var text: String
var real: float


static var _fields: Array[String] = ["number", "text", "real"]


static func wrap_query_result(query_result: Dictionary) -> TestTableORMEntry:
	var entry := TestTableORMEntry.new()
	
	for field in _fields:
		assert(query_result.has(field), "Invalid query result for that wrapper")
		entry.set(field, query_result[field])
	
	return entry


func _init() -> void:
	#HACK This is needed so plugin knows that id was unchanged, thus needs
	# to be ignored, when inserting that entry. That being said, this probably
	# could be done better
	if "id" in _fields:
		set("id", -1)


func get_entry_dict() -> Dictionary:
	var dict := super.get_entry_dict()
	
	for field in _fields:
		dict[field] = get(field)
	
	if "id" in _fields and get("id") == -1:
		dict.erase("id")
	
	return dict


func _to_string() -> String:
	var message := "<TestTableEntry: "
	for field in _fields:
		message += "%s(%s), " % [field, get(field)]
	message = message.erase(message.length()-2, 2)
	message += ">"
	return message
