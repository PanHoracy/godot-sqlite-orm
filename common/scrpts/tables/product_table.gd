extends ORMIdTable

var product_name := ORMStringColumnBuilder.new().set_not_null().build()
var price := ORMFloatColumnBuilder.new().build()
var producer_id := ORMForeignKeyColumnBuilder.new(DB.producer_table.id).build()
