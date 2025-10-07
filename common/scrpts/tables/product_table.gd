extends ORMIdTable

var product_name := ORMStringColumn.new().set_not_null()
var price := ORMFloatColumn.new()
