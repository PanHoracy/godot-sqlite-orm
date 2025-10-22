extends ORMIdTable

var product_name := ORMStringColumn.new().set_not_null()
var price := ORMFloatColumn.new()
#var producer_id := ORMForeignKeyColumn.new(DB.producer_table.id)
