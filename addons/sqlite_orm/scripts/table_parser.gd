@tool
class_name TableParser extends RefCounted

#TODO parser is not removing table from database autoload after its file is removed
#TODO rename to ORMTableParser

const GEN_CLASSES_FOLDER_PATH: String = "res://addons/sqlite_orm/scripts/generated/"
const TABLE_ENTRY_TEMPLATE_FILE_PATH: String = "res://addons/sqlite_orm/scripts/common/table_entry_template.txt"
const TABLE_GEN_TEMPLATE_FILE_PATH: String = "res://addons/sqlite_orm/scripts/common/table_class_template.txt"
const TABLE_VAR_TEMPLATE_FILE_PATH: String = "res://addons/sqlite_orm/scripts/common/table_variable_template.txt"
const ID_TABLE_EXTENSION_FILE_PATH: String = "res://addons/sqlite_orm/scripts/common/id_table_extension.txt"
const AUTOLOAD_SCRIPT_PATH: String = "res://addons/sqlite_orm/scripts/database.gd"


static func parse(dir_path: String) -> void:
	## Get directory with table definitions
	var tab_dir := _get_dir_access(dir_path, "table definitions")
	if tab_dir == null:
		return
	
	## Get directory with generated files
	var gen_dir := _get_dir_access(GEN_CLASSES_FOLDER_PATH, "generated classes")
	if gen_dir == null:
		return
	
	var gen_classes_files := gen_dir.get_files()
	
	_clear_autoload_variables()
	
	for file_name in tab_dir.get_files():
		if not file_name.ends_with(".gd"):
			continue
		
		## Generate class name and file name for table class
		var gen_db_variable := file_name.strip_edges().get_basename().to_lower()
		var gen_class_name := gen_db_variable.to_pascal_case()
		var gen_class_file_name := "gen_" + gen_class_name.to_snake_case() + ".gd"
		var gen_class_entry_file_name := "gen_" + gen_class_name.to_snake_case() + "_entry.gd"
		
		## Remove generated class file names from list with all current files in generated folder
		## The files that are not removed are assumed that shuldn't be there, and are therefor removed
		if gen_classes_files.has(gen_class_file_name):
			gen_classes_files.remove_at(gen_classes_files.find(gen_class_file_name))
		if gen_classes_files.has(gen_class_entry_file_name):
			gen_classes_files.remove_at(gen_classes_files.find(gen_class_entry_file_name))
		
		## Accessing columns from table definition
		var definition_file_path := dir_path+file_name
		var definition_file := FileAccess.open(definition_file_path, FileAccess.READ)
		if definition_file == null:
			push_error("Error while opening table definition file. Error code: %d" % FileAccess.get_open_error())
			assert(false)
		
		var columns: Dictionary[String, String] = _get_columns_from_table_definition_file(definition_file)
		
		#HACK This should be done in more realiable way (may cause edge case errors)
		var has_id_extension: bool = definition_file.get_as_text().contains("IdTable")
		
		if has_id_extension:
			columns["id"] = "int"
		
		## Create rest of parameters to propagate template files
		var columns_listing := ""
		for var_name in columns.keys():
			columns_listing += var_name + ", "
		
		var column_names := ""
		for var_name in columns.keys():
			column_names += "%s.name = '%s'\n\t" % [var_name, var_name]
		
		var function_extensions := ""
		if has_id_extension:
			var id_enstension_file: FileAccess = FileAccess.open(ID_TABLE_EXTENSION_FILE_PATH, FileAccess.READ)
			if id_enstension_file == null:
				push_error("Error while opening a file (%s). Error code: %d" % [ID_TABLE_EXTENSION_FILE_PATH, FileAccess.get_open_error()])
				return
			function_extensions = id_enstension_file.get_as_text().format({"class_name": gen_class_name})
		
		var class_params := GenClassFileParams.new()
		class_params.gen_class_name = gen_class_name
		class_params.script_path = definition_file_path
		class_params.table_name = gen_db_variable
		class_params.columns = columns_listing
		class_params.setting_column_names = column_names
		class_params.function_extensions = function_extensions
		
		_create_and_fill_generated_class_file(gen_class_file_name, class_params)
		
		var entry_vars := ""
		var entry_var_names := ''
		for var_name in columns.keys():
			entry_vars += "var %s: %s\n" % [var_name, columns[var_name]]
			entry_var_names += '"%s", ' % var_name
		entry_var_names = entry_var_names.substr(0, entry_var_names.length()-2)
		
		var entry_params := GenEntryParams.new()
		entry_params.gen_class_name = gen_class_name
		entry_params.entry_vars = entry_vars
		entry_params.entry_var_names = entry_var_names
		
		_create_and_fill_generated_class_entry_file(gen_class_entry_file_name, entry_params)
		_add_gen_class_to_autoload(gen_db_variable, gen_class_name)
	
	## Remove generated files that have no use anymore
	for file_name in gen_classes_files:
		_remove_gen_file(file_name)


static func _clear_autoload_variables() -> void:
	var autoload_file := FileAccess.open(AUTOLOAD_SCRIPT_PATH, FileAccess.READ_WRITE)
	if autoload_file == null:
		push_error("Error while opening the file (%s). Error code: %d" % [AUTOLOAD_SCRIPT_PATH.get_file(), FileAccess.get_open_error()])
		return
	
	var autoload_content := autoload_file.get_as_text()
	
	var region_line := "#region Tables"
	var start := autoload_content.find(region_line) + region_line.length()
	var end := autoload_content.find("#endregion")
	autoload_content = autoload_content.erase(start, end-start-1)
	
	var tables_var := "@onready var _tables: Array[Table] = ["
	start = autoload_content.find(tables_var) + tables_var.length()
	end = autoload_content.find("]", start)
	autoload_content = autoload_content.erase(start, end-start)
	
	if start == -1 or end == -1:
		push_error("Something went wrong while clearing the file")
		return
	
	autoload_file.seek(autoload_file.get_length())
	autoload_file.resize(0)
	autoload_file.seek(0)
	autoload_file.store_string(autoload_content)


static func _get_columns_from_table_definition_file(table_definition_file: FileAccess) -> Dictionary[String, String]:
	## Going through table definition content
	var columns: Dictionary[String, String] = {}
	while table_definition_file.get_position() < table_definition_file.get_length():
		var line := table_definition_file.get_line()
		if not line.begins_with("var"):
			continue
		
		## Reading variable name (will be used as column name later)
		var start := "var ".length()
		var end := line.find(":") if line.contains(":") else line.find("=")
		var var_name := line.substr(start, end-start).strip_edges()
		
		if line.contains("IntColumn") or line.contains("PkColumn"):
			columns[var_name] = "int"
		elif line.contains("FloatColumn"):
			columns[var_name] = "float"
		elif line.contains("StringColumn"):
			columns[var_name] = "String"
	
	return columns


class GenEntryParams:
	extends RefCounted
	
	var gen_class_name: String
	var entry_vars: String
	var entry_var_names: String


static func _create_and_fill_generated_class_entry_file(gen_file_name: String, params: GenEntryParams) -> void:
	var gen_entry_file: FileAccess = FileAccess.open(GEN_CLASSES_FOLDER_PATH.path_join(gen_file_name), FileAccess.WRITE)
	if gen_entry_file == null:
		push_error("Error while opening a file (%s). Error code: %d" % [gen_file_name, FileAccess.get_open_error()])
		return
	
	## Loading content of template file
	var template_string: String
	var template_file := FileAccess.open(TABLE_ENTRY_TEMPLATE_FILE_PATH, FileAccess.READ)
	if template_file == null:
		push_error("Error while opening a file (%s). Error code: %d" % [TABLE_ENTRY_TEMPLATE_FILE_PATH.get_file(), FileAccess.get_open_error()])
		return
	template_string = template_file.get_as_text()
	
	## Fill template with data and save to generated file
	template_string = template_string.format({
		"class_name": params.gen_class_name,
		"entry_vars": params.entry_vars,
		"own_file_name": gen_file_name,
		"entry_fields": params.entry_var_names
	})
	gen_entry_file.store_string(template_string)


class GenClassFileParams:
	extends RefCounted
	
	var gen_class_name: String
	var script_path: String
	var table_name: String
	var columns: String
	var setting_column_names: String
	var function_extensions: String


static func _create_and_fill_generated_class_file(gen_file_name: String, params: GenClassFileParams) -> void:
	## Open and truncate / Create file for generated class
	var gen_class_file: FileAccess = FileAccess.open(GEN_CLASSES_FOLDER_PATH.path_join(gen_file_name), FileAccess.WRITE)
	if gen_class_file == null:
		push_error("Error while opening a file (%s). Error code: %d" % [gen_file_name, FileAccess.get_open_error()])
		return
	
	## Loading content of template file
	var template_string: String
	var template_file := FileAccess.open(TABLE_GEN_TEMPLATE_FILE_PATH, FileAccess.READ)
	if template_file == null:
		push_error("Error while opening a file (%s). Error code: %d" % [TABLE_GEN_TEMPLATE_FILE_PATH.get_file(), FileAccess.get_open_error()])
		return
	template_string = template_file.get_as_text()
	
	## Fill template with data and save to generated file
	template_string = template_string.format({
		"class_name": params.gen_class_name,
		"script_path": params.script_path,
		"table_name": params.table_name,
		"columns": params.columns,
		"setting_column_names": params.setting_column_names,
		"function_extensions": params.function_extensions
	})
	gen_class_file.store_string(template_string)


static func _add_gen_class_to_autoload(name_of_variable: String, name_of_class: String) -> void:
	var autoload_file := FileAccess.open(AUTOLOAD_SCRIPT_PATH, FileAccess.READ_WRITE)
	if autoload_file == null:
		push_error("Error while opening the file (%s). Error code: %d" % [AUTOLOAD_SCRIPT_PATH.get_file(), FileAccess.get_open_error()])
		return
	
	var template_file := FileAccess.open(TABLE_VAR_TEMPLATE_FILE_PATH, FileAccess.READ)
	if template_file == null:
		push_error("Error while opening the file (%s). Error code: %d" % [TABLE_VAR_TEMPLATE_FILE_PATH.get_file(), FileAccess.get_open_error()])
		return
	
	var template_string := template_file.get_as_text().strip_edges()
	var autoload_content := autoload_file.get_as_text()
	
	var region_line := "#region Tables"
	var start := autoload_content.find(region_line) + region_line.length()
	autoload_content = autoload_content.insert(start, "\n" + template_string.format({"variable_name": name_of_variable, "class_name": name_of_class}))
	
	var tables_var := "@onready var _tables: Array[Table] = ["
	start = autoload_content.find(tables_var) + tables_var.length()
	autoload_content = autoload_content.insert(start, "%s, " % name_of_variable)
	
	autoload_file.store_string(autoload_content)


static func _remove_gen_file(file: String) -> void:
	var gen_dir := _get_dir_access(GEN_CLASSES_FOLDER_PATH, "generated classes")
	if gen_dir == null:
		return
	
	var err:= gen_dir.remove(file) 
	if err != OK:
		push_error("Error while removing the file %s. Error code: %d" % [file, err])


static func _get_dir_access(path: String, message: String) -> DirAccess:
	var dir_acc := DirAccess.open(path)
	
	if dir_acc == null:
		var err_code := DirAccess.get_open_error()
		push_error("Error while opening directory with %s. Error code: %d" % [message, err_code])
		return null
	
	return dir_acc


static func _delete_file(path: String) -> void:
	var dir_acc := _get_dir_access(path.get_base_dir(), "genereted classes")
	if dir_acc == null:
		return
	
	if dir_acc.file_exists(path):
		dir_acc.remove(path.get_file())
	else:
		push_error("No such file as %s" % path)
