extends ORMIdTable

var producer_name := ORMStringColumnBuilder.new().set_not_null().set_default("Unset").build()
