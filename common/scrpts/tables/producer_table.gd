extends ORMIdTable

var producer_name := ORMStringColumn.new().set_not_null().set_default("Unset")
