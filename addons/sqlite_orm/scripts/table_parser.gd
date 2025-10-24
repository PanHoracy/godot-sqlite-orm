@tool
class_name ORMTableParser extends RefCounted

#TODO parser is not removing table from database autoload after its file is removed
#TODO make so that fields in table entry classes have default values that match column default values
#FIXME if column is removed or renamed in definition file it displays error (that doesn't do anything, other then being annoying)

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
	
	var tables_with_foregin_keys: Dictionary[String, Dictionary] = {}
	
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
		var has_id_extension: bool = definition_file.get_as_text().contains("ORMIdTable")
		var has_fk_column: bool = definition_file.get_as_text().contains("ORMForeignKeyColumnBuilder")
		
		#FIXME Why is it here? _get_columns_from_table_definition_file() should already cover this
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
		
		if has_fk_column:
			tables_with_foregin_keys[gen_class_name] = {
				"variable_name": gen_db_variable,
				"table_file": definition_file
			}
			_add_gen_class_to_autoload_no_init(gen_db_variable, gen_class_name)
		else:
			_add_gen_class_to_autoload_with_init(gen_db_variable, gen_class_name)
	
	#TODO Check if self referencing tables work with this system
	# Remember to remove safeguard in fk_column (assert checking if referenced table if different then self table)
	
	var initialization_order: Array[String] = []
	var tables_left: Array[String] = tables_with_foregin_keys.keys()
	
	for table_name in tables_left:
		tables_with_foregin_keys[table_name]["references"] = _get_table_fk_references(tables_with_foregin_keys[table_name]["table_file"])
	
	var variable_to_table_name: Dictionary[String, String] = {}
	for table_name in tables_left:
		variable_to_table_name[tables_with_foregin_keys[table_name]["variable_name"]] = table_name
	
	## Check if table references table without fk. If it is can be initialized
	## first, as tables without fk are already initialized.
	for table_name in tables_left:
		var ref_safety_dict: Dictionary[String, bool] = {}
		
		for ref_var_name in tables_with_foregin_keys[table_name]["references"]:
			ref_safety_dict[ref_var_name] = not variable_to_table_name.has(ref_var_name)
		
		if not ref_safety_dict.values().has(false):
			## Assume that all referenced tables have no fk
			initialization_order.push_back(table_name)
			tables_left.erase(table_name)
	
	## Remove references to tables with no fk, and swap table variable names to
	## table names for convinience
	for table_name in tables_left:
		for ref_var_name in tables_with_foregin_keys[table_name]["references"]:
			var new_references: Array[String] = []
			
			if variable_to_table_name.has(ref_var_name):
				var reference_table_name := variable_to_table_name[ref_var_name]
				new_references.append(reference_table_name)
			else:
				tables_with_foregin_keys[table_name]["references"].erase(ref_var_name)
			
			tables_with_foregin_keys[table_name]["references"] = new_references
	
	#HACK This probably could be done better
	## We cycle through every table and check if referenced table is already in
	## initialization_order. If it is, we can safely put it in there and remove from tables_left
	## If tables_left is not empty, and nothing was moved to initalization_order
	## that measn there is a circular dependency somewhere
	while not tables_left.is_empty():
		var changed_something := false
		
		for table_name in tables_left:
			var ref_safety_dict: Dictionary[String, bool] = {}
			
			for ref_var_name in tables_with_foregin_keys[table_name]["references"]:
				ref_safety_dict[ref_var_name] = initialization_order.has(ref_var_name) 
			
			if not ref_safety_dict.values().has(false):
				## Assume that all referenced tables are already initialized
				initialization_order.push_back(table_name)
				tables_left.erase(table_name)
				changed_something = true
		
		if not changed_something:
			push_error("Some tables have circular foreign key dependencies, which is not supported")
			break
	
	var autoload_file := FileAccess.open(AUTOLOAD_SCRIPT_PATH, FileAccess.READ_WRITE)
	if autoload_file == null:
		push_error("Error while opening the file (%s). Error code: %d" % [AUTOLOAD_SCRIPT_PATH.get_file(), FileAccess.get_open_error()])
		return
	
	var autoload_content := autoload_file.get_as_text()
	var func_def := "func _initialize_fk_tables() -> void:"
	var start := autoload_content.find(func_def) + func_def.length()+2 #+2 because of new line and tab
	
	initialization_order.reverse()
	for table_name in initialization_order:
		var code_to_add := "{variable_name} = {table_name}ORM.new()\n\t_tables.append({variable_name})\n\t"
		code_to_add = code_to_add.format({"variable_name": tables_with_foregin_keys[table_name]["variable_name"], "table_name": table_name})
		autoload_content = autoload_content.insert(start, code_to_add)
	
	autoload_file.store_string(autoload_content)
	
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
	
	var tables_var := "@onready var _tables: Array[ORMTable] = ["
	start = autoload_content.find(tables_var) + tables_var.length()
	end = autoload_content.find("]", start)
	autoload_content = autoload_content.erase(start, end-start)
	
	var fk_tables_func := "func _initialize_fk_tables() -> void:"
	start = autoload_content.find(fk_tables_func) + fk_tables_func.length()+2 # +2 because of new line and tab
	end = autoload_content.find("tables_ready.emit()", start)
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
		
		if line.contains("ORMIntColumnBuilder") or line.contains("ORMPrimaryKeyColumn") or line.contains("ORMForeignKeyColumnBuilder"):
			columns[var_name] = "int"
		elif line.contains("ORMFloatColumnBuilder"):
			columns[var_name] = "float"
		elif line.contains("ORMStringColumnBuilder"):
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


static func _add_gen_class_variable_to_autoload(template_string: String, name_of_variable: String, name_of_class: String) -> void:
	var autoload_file := FileAccess.open(AUTOLOAD_SCRIPT_PATH, FileAccess.READ_WRITE)
	if autoload_file == null:
		push_error("Error while opening the file (%s). Error code: %d" % [AUTOLOAD_SCRIPT_PATH.get_file(), FileAccess.get_open_error()])
		return
	
	var autoload_content := autoload_file.get_as_text()
	
	var region_line := "#region Tables"
	var start := autoload_content.find(region_line) + region_line.length()
	autoload_content = autoload_content.insert(start, "\n" + template_string.format({"variable_name": name_of_variable, "class_name": name_of_class}))
	
	autoload_file.store_string(autoload_content)


static func _add_gen_class_table_to_table_array(name_of_variable) -> void:
	var autoload_file := FileAccess.open(AUTOLOAD_SCRIPT_PATH, FileAccess.READ_WRITE)
	if autoload_file == null:
		push_error("Error while opening the file (%s). Error code: %d" % [AUTOLOAD_SCRIPT_PATH.get_file(), FileAccess.get_open_error()])
		return
	
	var autoload_content := autoload_file.get_as_text()
	
	var tables_var := "@onready var _tables: Array[ORMTable] = ["
	var start := autoload_content.find(tables_var) + tables_var.length()
	autoload_content = autoload_content.insert(start, "%s, " % name_of_variable)
	
	autoload_file.store_string(autoload_content)


static func _add_gen_class_to_autoload_with_init(name_of_variable: String, name_of_class: String) -> void:
	_add_gen_class_variable_to_autoload("var {variable_name}: {class_name}ORM = {class_name}ORM.new()", name_of_variable, name_of_class)
	_add_gen_class_table_to_table_array(name_of_variable)


static func _add_gen_class_to_autoload_no_init(name_of_variable: String, name_of_class: String) -> void:
	_add_gen_class_variable_to_autoload("var {variable_name}: {class_name}ORM", name_of_variable, name_of_class)


static func _get_table_fk_references(table_file: FileAccess) -> Array[String]:
	var result: Array[String] = []
	
	table_file.seek(0)
	while table_file.get_position() < table_file.get_length():
		var line := table_file.get_line()
		
		var text_trigger := "ORMForeignKeyColumnBuilder.new("
		var start := line.find(text_trigger) + text_trigger.length()
		if start == (-1 + text_trigger.length()):
			continue
		
		var end := line.find(")", start)
		var reference_text := line.substr(start, end-start).split(".")
		
		if reference_text.size() < 2 or reference_text[0] != "DB":
			push_error("It is expected that ORMForeignKeyColumnBuilder will be provided with reference to table from DB autoload")
			break
		
		result.push_back(reference_text[1])
	
	return result


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
