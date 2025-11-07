extends Control


func _ready() -> void:
	print("Number: ", DB.test_table.number.get_sum())
	print("Text: ", DB.test_table.text.get_sum())
	print("Real: ", DB.test_table.real.get_sum())


func read_all_from_test_table() -> void:
	for entry in DB.test_table.get_all():
		print(entry)


func read_all_from_product() -> void:
	for entry in DB.product.get_all():
		print(entry)


func insert_things_to_test_table() -> void:
	var test_entry := TestTableORMEntry.new()
	var entries: Array[TestTableORMEntry] = []
	for i in 10:
		var entry := TestTableORMEntry.new()
		entry.number = i+1
		entry.text = "This is %s entry of array add" % i
		entry.real = snappedf(randf_range(0.0, 5.0), 0.1)
		entries.push_back(entry)
	
	test_entry.number = 11
	test_entry.text = "This is a solo value"
	test_entry.real = 5.5
	
	DB.test_table.put_entry_into_table(test_entry)
	DB.test_table.put_entries_array_into_table(entries)


func insert_things_to_leaderboard() -> void:
	var players: Array[String] = ["SuperDude", "GreatPlayer", "ItsMe", "Karl"]
	
	for player in players:
		for i in randi_range(3, 7):
			var entry := LeaderboardORMEntry.new()
			entry.player_name = player
			entry.score = randi_range(1, 100)
			DB.leaderboard.put_entry_into_table(entry)


func insert_things_to_products() -> void:
	var producer_entry := ProducerTableORMEntry.new()
	producer_entry.producer_name = "MSI"
	DB.producer_table.put_entry_into_table(producer_entry)
	
	producer_entry = ProducerTableORMEntry.new()
	producer_entry.producer_name = "Lenovo"
	DB.producer_table.put_entry_into_table(producer_entry)
	
	producer_entry = ProducerTableORMEntry.new()
	producer_entry.producer_name = "Dell"
	DB.producer_table.put_entry_into_table(producer_entry)
	
	producer_entry = ProducerTableORMEntry.new()
	producer_entry.producer_name = "Asus"
	DB.producer_table.put_entry_into_table(producer_entry)
	
	var product_entry := ProductTableORMEntry.new()
	product_entry.product_name = "Alpha 17"
	product_entry.price = 7_400
	product_entry.producer_id = 1
	DB.product_table.put_entry_into_table(product_entry)
	
	product_entry = ProductTableORMEntry.new()
	product_entry.product_name = "Leopard 17"
	product_entry.price = 5_500
	product_entry.producer_id = 1
	DB.product_table.put_entry_into_table(product_entry)
	
	product_entry = ProductTableORMEntry.new()
	product_entry.product_name = "Katana 15"
	product_entry.price = 8_500
	product_entry.producer_id = 1
	DB.product_table.put_entry_into_table(product_entry)
	
	product_entry = ProductTableORMEntry.new()
	product_entry.product_name = "Legion 5i"
	product_entry.price = 6_000
	product_entry.producer_id = 2
	DB.product_table.put_entry_into_table(product_entry)
	
	product_entry = ProductTableORMEntry.new()
	product_entry.product_name = "Ideapad 320"
	product_entry.price = 2_500
	product_entry.producer_id = 2
	DB.product_table.put_entry_into_table(product_entry)
	
	product_entry = ProductTableORMEntry.new()
	product_entry.product_name = "Legion 7"
	product_entry.price = 8_000
	product_entry.producer_id = 2
	DB.product_table.put_entry_into_table(product_entry)
	
	product_entry = ProductTableORMEntry.new()
	product_entry.product_name = "Yoga 5"
	product_entry.price = 6_400
	product_entry.producer_id = 2
	DB.product_table.put_entry_into_table(product_entry)
	
	product_entry = ProductTableORMEntry.new()
	product_entry.product_name = "Alienware 17"
	product_entry.price = 9_000
	product_entry.producer_id = 3
	DB.product_table.put_entry_into_table(product_entry)
	
	product_entry = ProductTableORMEntry.new()
	product_entry.product_name = "TUF 16"
	product_entry.price = 5_750
	product_entry.producer_id = 4
	DB.product_table.put_entry_into_table(product_entry)
	
	product_entry = ProductTableORMEntry.new()
	product_entry.product_name = "ROG Strix G16"
	product_entry.price = 9_150
	product_entry.producer_id = 4
	DB.product_table.put_entry_into_table(product_entry)
	
	product_entry = ProductTableORMEntry.new()
	product_entry.product_name = "ROG Strix G18"
	product_entry.price = 11_250
	product_entry.producer_id = 4
	DB.product_table.put_entry_into_table(product_entry)
	
	var review_entry := ProductReviewORMEntry.new()
	review_entry.title = "Excellent performance"
	review_entry.content = "Great laptop"
	review_entry.product_id = 1
	DB.product_review.put_entry_into_table(review_entry)
	
	review_entry = ProductReviewORMEntry.new()
	review_entry.title = "Great price"
	review_entry.content = "Astonishing price for this class of hardware"
	review_entry.product_id = 1
	DB.product_review.put_entry_into_table(review_entry)
	
	review_entry = ProductReviewORMEntry.new()
	review_entry.title = "Incredible"
	review_entry.content = "Great performance"
	review_entry.product_id = 2
	DB.product_review.put_entry_into_table(review_entry)
	
	review_entry = ProductReviewORMEntry.new()
	review_entry.title = "Very affordable"
	review_entry.content = "Great price"
	review_entry.product_id = 5
	DB.product_review.put_entry_into_table(review_entry)
	
	review_entry = ProductReviewORMEntry.new()
	review_entry.title = "My best buy yet"
	review_entry.content = "Nothing comes even close"
	review_entry.product_id = 10
	DB.product_review.put_entry_into_table(review_entry)


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
