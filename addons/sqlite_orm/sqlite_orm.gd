@tool
extends EditorPlugin

const UTILS := preload("res://addons/sqlite_orm/scripts/common/utils.gd")

const AUTOLOAD_NAME: String = "DB"


func _enter_tree() -> void:
	UTILS.update_plugin_settings()
	
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/sqlite_orm/scripts/database.gd")


func _exit_tree() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)


func _save_external_data() -> void:
	TableParser.parse(ProjectSettings.get_setting(UTILS.TABLE_FOLDER_PATH_SP))
	EditorInterface.get_resource_filesystem().scan()
