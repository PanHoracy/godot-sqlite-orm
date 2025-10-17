extends Control


func _ready() -> void:
	var table := DB.test_table
	var entries := table.get_all()
	for entry in entries:
		print(entry)
	
	print("-------")
	
	print(table.create_select_query().select_columns([table.number]).get_as_raw_result())
	
	print("-------")
	
	entries = table.get_all()
	for entry in entries:
		print(entry)


func read_all_from_test_table() -> void:
	for entry in DB.test_table.get_all():
		print(entry)


func read_all_from_product() -> void:
	for entry in DB.product.get_all():
		print(entry)


func insert_things_to_product() -> void:
	var entry: ProductTableORMEntry
	
	entry = ProductTableORMEntry.new()
	entry.price = 50.0
	entry.product_name = "Game"
	DB.product.put_entry_into_table(entry)
	
	entry = ProductTableORMEntry.new()
	entry.price = 700.0
	entry.product_name = "Phone"
	DB.product.put_entry_into_table(entry)
	
	entry = ProductTableORMEntry.new()
	entry.price = 2.0
	entry.product_name = "Bread"
	DB.product.put_entry_into_table(entry)
	
	entry = ProductTableORMEntry.new()
	entry.price = 15.0
	entry.product_name = "Skin"
	DB.product.put_entry_into_table(entry)


func insert_things_to_test_table() -> void:
	var test_entry := TestTableORMEntry.new()
	var entries: Array[TestTableORMEntry] = []
	for i in 10:
		var entry := TestTableORMEntry.new()
		entry.number = i+1
		entry.text = "This is %s entry of array add" % i
		entry.real = randf_range(0.0, 5.0)
		entries.push_back(entry)
	
	test_entry.number = 11
	test_entry.text = "This is a solo value"
	test_entry.real = 5.5
	
	DB.test_table.put_entry_into_table(test_entry)
	DB.test_table.put_entries_array_into_table(entries)


func advanced_update_text() -> void:
	var table := DB.test_table
	var updated_row := TestTableORMEntry.new()
	updated_row.number = 25
	table.create_update_query()\
		.set_updated_row(updated_row)\
		.select_columns([table.number])\
		.where(table.number.less_then(100))\
		.order_by_asc(table.number)\
		.limit(4)\
		.update()
