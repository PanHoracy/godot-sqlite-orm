extends Node

#region: Settings keys and default values
## SP stands for Settings Path
const SP_BASE: String = "plugins/SQLite ORM/"

# Table folder path
const TABLE_FOLDER_PATH_SP := SP_BASE + "Table folder path"
const _DEFAULT_TABLE_FORLDER_PATH := "res://common/scrpts/tables/"

# Database path
const DATABASE_PATH_SP := SP_BASE + "Database path"
const _DEFAULT_DATABASE_PATH := "user://database.db"

# Verbosity level
const VERBOSITY_LEVEL_SP := SP_BASE + "Verbosity level"
const _DEFAULT_VERBOSITY_LEVEL := 1
const _VERBOSITY_LEVEL_PROPERTY_INFO := {
	"name": VERBOSITY_LEVEL_SP,
	"type": TYPE_INT,
	"hint": PROPERTY_HINT_ENUM,
	"hint_string": "Quiet,Normal,Verbose,Very Verbose"
}
#endregion

static func print_humanized_dict(dict: Dictionary, header: String = "Dictionary") -> void:
	var text := "{\n"
	for key in dict.keys():
		text += "\t%s: %s\n" % [str(key), str(dict[key])]
	text += "}"
	
	print()
	print(header)
	print(text)
	print()


static func update_plugin_settings() -> void:
	if not ProjectSettings.has_setting(TABLE_FOLDER_PATH_SP):
		ProjectSettings.set_setting(TABLE_FOLDER_PATH_SP, _DEFAULT_TABLE_FORLDER_PATH)
		ProjectSettings.set_initial_value(TABLE_FOLDER_PATH_SP, _DEFAULT_TABLE_FORLDER_PATH)
	
	if not ProjectSettings.has_setting(DATABASE_PATH_SP):
		ProjectSettings.set_setting(DATABASE_PATH_SP, _DEFAULT_DATABASE_PATH)
		ProjectSettings.set_initial_value(DATABASE_PATH_SP, _DEFAULT_DATABASE_PATH)
	
	if not ProjectSettings.has_setting(VERBOSITY_LEVEL_SP):
		ProjectSettings.set_setting(VERBOSITY_LEVEL_SP, _DEFAULT_VERBOSITY_LEVEL)
		ProjectSettings.set_initial_value(VERBOSITY_LEVEL_SP, _DEFAULT_VERBOSITY_LEVEL)
		ProjectSettings.add_property_info(_VERBOSITY_LEVEL_PROPERTY_INFO)
