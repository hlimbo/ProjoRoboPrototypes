extends Node

class ItemQuantity:
	var item: LootItem
	var quantity: int
	# this allows one to lookup where the item is located in the array
	var index: int

# key - item_name string
# value - ItemQuantity Resource
var inventory_map: Dictionary = {}
# key - index int
# value - item_name string
var inventory_array: Array[String]

func _check_assertions(item: ItemQuantity):
	assert(item != null, "item cannot be null")
	assert(item.item != null, "item's item cannot be null")
	assert(item.quantity > 0, "quantity must be > 0")

# returns item's quantity from the inventory
func add(item: ItemQuantity) -> int:
	_check_assertions(item)
	
	# add to quantity if item already in inventory
	if item.item.item_name in inventory_map:
		inventory_map[item.item.item_name].quantity += item.quantity
		return inventory_map[item.item.item_name].quantity
	
	# this may add an item that has at least 1 or more of its kind
	inventory_map[item.item.item_name] = item
	inventory_array.append(item.item.item_name)
	inventory_map[item.item.item_name].index = len(inventory_array) - 1

	return inventory_map[item.item.item_name].quantity

# returns number of items of same type removed
# returns 0 if item not found
func remove(item: ItemQuantity) -> int:
	_check_assertions(item)
	
	if item.item.item_name not in inventory_map:
		return 0
	
	# cannot remove quantity > inventory item quantity
	assert(item.quantity <= inventory_map[item.item_name].quantity)
	
	var removed_quantity: int = item.quantity
	inventory_map[item.item.item_name] -= removed_quantity
	
	# remove item from inventory
	if inventory_map[item.item.item_name].quantity == 0:
		inventory_map.erase(item.item.item_name)
	
		
		# slow - could be faster in terms of O-Notation
		# however would be more natural for the player to see items shift on a list then
		# having the last item in the list magically appear where the removed item was located
		var item_index: int = inventory_array.find(item.item.item_name)
		assert(item_index != -1)
		inventory_array.remove_at(item_index)
		# shift all indices by -1 to the right of item_index
	
	return removed_quantity
	
func swap(item_name1: String, item_name2: String):
	assert(item_name1 in inventory_map)
	assert(item_name2 in inventory_map)
	
	var index1: int = inventory_map[item_name1].index
	var index2: int = inventory_map[item_name2].index
	
	var temp_name: String = inventory_array[index1]
	inventory_array[index1] = inventory_array[index2]
	inventory_array[index2] = temp_name
	
	inventory_map[item_name1].index = index2
	inventory_map[item_name2].index = index1
