class_name ORMCondition extends RefCounted

var _condition: String = ""


func _init(condition: String) -> void:
	_condition = condition


func get_condition() -> String:
	return _condition


static func alternative(condition1: ORMCondition, condition2: ORMCondition) -> ORMCondition:
	var con1_string := condition1.get_condition()
	var con2_string := condition2.get_condition()
	
	if con1_string == "":
		push_warning("Trying to alternate with empty condition1")
	
	if con2_string == "":
		push_warning("Trying to alternate with empty condition2")
	
	return ORMCondition.new("(%s) OR (%s)" % [con1_string, con2_string])


static func conjunction(condition1: ORMCondition, condition2: ORMCondition) -> ORMCondition:
	var con1_string := condition1.get_condition()
	var con2_string := condition2.get_condition()
	
	if con1_string == "":
		push_warning("Trying to conjoin with empty condition1")
	
	if con2_string == "":
		push_warning("Trying to conjoin with empty condition2")
	
	return ORMCondition.new("(%s) AND (%s)" % [con1_string, con2_string])


func conjoin_with(other_condition: ORMCondition) -> ORMCondition:
	if _condition == "":
		push_warning("Trying to combine empty condition with and to other condition")
	
	var other_condition_string := other_condition.get_condition()
	if other_condition_string == "":
		push_warning("Trying to combine condition with and to empty condition")
	
	_condition = "%s AND %s" % [_condition, other_condition_string]
	return self


func alternate_with(other_condition: ORMCondition) -> ORMCondition:
	if _condition == "":
		push_warning("Trying to combine empty condition with or to other condition")
	
	var other_condition_string := other_condition.get_condition()
	if other_condition_string == "":
		push_warning("Trying to combine condition with or to empty condition")
	
	_condition = "%s OR %s" % [_condition, other_condition_string]
	return self
