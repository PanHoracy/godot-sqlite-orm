extends ORMTable

var number := ORMIntColumn.new().set_default(100)
var text:= ORMStringColumn.new().set_not_null().set_unique()
var real :=ORMFloatColumn.new().set_default(7.0)
