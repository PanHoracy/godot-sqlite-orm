extends ORMIdTable

var player_name := ORMStringColumnBuilder.new().set_default("Player 1").set_not_null().build()
var score := ORMIntColumnBuilder.new().set_not_null().set_old_names("player_score").build()
