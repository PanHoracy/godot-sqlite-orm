extends Control


func _ready() -> void:
	var _number := DB.test_table.number
	var _real := DB.test_table.real
	var _text := DB.test_table.text
	var result := DB.test_table.create_select_query()\
		.where(_real.is_not_null().and_also(_number.less_then(90)))\
		.get_entries()
	for entry in result:
		print(entry)
	print(result.size())


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
	var entries: Array = []
	for i in 3:
		var entry := TestTableORMEntry.new()
		entry.number = i+1
		entry.text = "This is %s entry of array add" % i
		entry.real = randf_range(0.0, 5.0)
		entries.push_back(entry)
	
	test_entry.number = 1
	test_entry.text = "This is a solo value"
	test_entry.real = 5.5
	
	DB.test_table.put_entry_into_table(test_entry)
	DB.test_table.put_entries_array_into_table(entries)
