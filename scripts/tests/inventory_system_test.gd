extends Node

@export var max_quantity: int = 256
@export var inventory_system: InventorySystem = InventorySystem
@export var utility: Utility = Utility
@export var res_path: String = "res://resources/loot"
var loot_items: Array[LootItem] = []
var items: Array[InventorySystem.ItemQuantity] = []

signal on_setup_test
signal on_teardown_test

func setup():
	var resources: Array[Resource] = utility.load_resources_from_folder(res_path)
	for res in resources:
		loot_items.append(res as LootItem)
		
	assert(len(loot_items) > 0)

func convert_to_item_quantities() -> Array[InventorySystem.ItemQuantity]:
	var items: Array[InventorySystem.ItemQuantity] = []
	for loot_item in loot_items:
		var item = inventory_system.ItemQuantity.new()
		item.item = loot_item
		item.quantity = randi() % max_quantity + 2
		items.append(item)
	
	return items

# adding
func add_item_test():
	# arrange
	on_setup_test.emit()
	# act
	inventory_system.add(items[0])
	# assert
	var item_from_inventory = inventory_system.get_item(items[0].item.item_name)
	var is_equivalent: bool = item_from_inventory.is_equal(items[0])
	assert(is_equivalent == true)
	
	on_teardown_test.emit()
	
# removing
func remove_item_test():
	# arrange
	on_setup_test.emit()
	var item_under_test: InventorySystem.ItemQuantity = InventorySystem.ItemQuantity.new()
	item_under_test.item = items[2].item
	item_under_test.quantity = items[2].quantity

	for item in items:
		inventory_system.add(item)
	
	# act 
	var removed_count: int = inventory_system.remove(item_under_test)
	
	# assert
	assert(removed_count == item_under_test.quantity)
	assert(inventory_system.get_item(item_under_test.item.item_name) == null)
	
	# check if indices are shifted by -1 -> to do this check if there is an index >= len(inventory_system)
	for item in items:
		var it = inventory_system.get_item(item.item.item_name)
		# skip removed item
		if it == null:
			continue
		assert(it.index < inventory_system.get_length())
		
	on_teardown_test.emit()

func remove_item_not_existing_test():
	# arrange
	on_setup_test.emit()
	
	# act
	var removed_count: int = inventory_system.remove(items[0])
	
	# assert
	assert(removed_count == 0)
	
	on_teardown_test.emit()

# does not completely remove item from inventory
func remove_item_with_set_quantity_test():
	# arrange
	on_setup_test.emit()
	inventory_system.add(items[0])
	# ensure quantity > 1
	items[0].quantity = 5
	
	var copy = InventorySystem.ItemQuantity.new()
	copy.item = items[0].item
	copy.quantity = 3

	# act
	var removed_count: int = inventory_system.remove(copy)
	
	# assert
	assert(removed_count == copy.quantity)
	
	on_teardown_test.emit()

func increase_item_count_test():
	# arrange
	on_setup_test.emit()
	inventory_system.add(items[0])
	
	# act
	var quantity: int = inventory_system.increase_item_count(items[0].item.item_name, 3)
	
	# assert
	assert(quantity == inventory_system.get_item(items[0].item.item_name).quantity)
	
func decrease_item_count_test():
	# arrange
	on_setup_test.emit()
	inventory_system.add(items[0])
	# ensure item count > 1
	items[0].quantity = 10
	
	# act
	var quantity: int = inventory_system.decrease_item_count(items[0].item.item_name, 4)
	
	# assert
	assert(quantity == inventory_system.get_item(items[0].item.item_name).quantity)


func decrease_item_count_all_test():
	# arrange
	on_setup_test.emit()
	inventory_system.add(items[0])
	# ensure item count > 1
	items[0].quantity = 10
	
	# act
	var quantity: int = inventory_system.decrease_item_count(items[0].item.item_name, 10)
	
	# assert
	assert(quantity == inventory_system.get_item(items[0].item.item_name).quantity)


# swapping
func swap_test():
	# arrange
	var items: Array[InventorySystem.ItemQuantity] = convert_to_item_quantities()
	for item in items:
		inventory_system.add(item)
	
	var item0 = inventory_system.get_item(items[0].item.item_name)
	var item1 = inventory_system.get_item(items[1].item.item_name)
	var item0_index: int = item0.index
	var item1_index: int = item1.index
		
	# act
	inventory_system.swap(items[0].item.item_name, items[1].item.item_name)
	
	# assert
	assert(inventory_system.get_item(items[0].item.item_name).index == item1_index)
	assert(inventory_system.get_item(items[1].item.item_name).index == item0_index)
	assert(inventory_system.inventory_array[item1_index] == items[0].item.item_name)
	assert(inventory_system.inventory_array[item0_index] == items[1].item.item_name)

	on_teardown_test.emit()

func _ready():
	on_setup_test.connect(setup_test)
	on_teardown_test.connect(clear_inventory)
	
	setup()
	add_item_test()
	remove_item_test()
	remove_item_not_existing_test()
	remove_item_with_set_quantity_test()
	increase_item_count_test()
	decrease_item_count_test()
	decrease_item_count_all_test()
	swap_test()

func setup_test():
	items = convert_to_item_quantities()
	
func clear_inventory():
	inventory_system.clear()
	
