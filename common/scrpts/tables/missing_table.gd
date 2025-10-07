extends ORMIdTable

var test := ORMIntColumn.new()
var missing_column := ORMStringColumn.new().set_not_null().set_default("Testing")
