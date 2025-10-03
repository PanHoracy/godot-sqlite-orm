extends Table

var number := IntColumn.new().set_default(100)
var text:= StringColumn.new().set_not_null().set_unique()
var real :=FloatColumn.new().set_default(7.0)
