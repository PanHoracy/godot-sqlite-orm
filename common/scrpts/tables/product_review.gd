extends ORMIdTable

var title := ORMStringColumnBuilder.new().set_not_null().set_default("Review title").build()
var content := ORMStringColumnBuilder.new().build()
var product_id := ORMForeignKeyColumnBuilder.new(DB.product_table.id).build()
