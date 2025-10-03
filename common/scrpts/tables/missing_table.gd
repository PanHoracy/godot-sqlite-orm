extends IdTable

var test := IntColumn.new()
var missing_column := StringColumn.new().set_not_null().set_default("Testing")
