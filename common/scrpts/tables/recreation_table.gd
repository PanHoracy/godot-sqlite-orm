extends ORMIdTable

var renamed_column := ORMStringColumnBuilder.new().set_old_names("column_to_rename").build()
var column_with_changed_default := ORMStringColumnBuilder.new().set_default("different default").build()
var column_to_not_null := ORMIntColumnBuilder.new().set_not_null().build()
var column_to_not_null_with_default := ORMIntColumnBuilder.new().set_default(1).set_not_null().build()
var column_to_unique := ORMIntColumnBuilder.new().set_unique().build()
