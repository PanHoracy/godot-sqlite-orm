extends ORMTable

var number := ORMIntColumnBuilder.new().set_not_null().set_unique().build()
var text:= ORMStringColumnBuilder.new().set_not_null().set_unique().build()
var real :=ORMFloatColumnBuilder.new().set_default(7.0).build()
