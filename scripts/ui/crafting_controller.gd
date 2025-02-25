extends Node
class_name CraftingController

# Dependencies
@export var inventory_system: InventorySystem = InventorySystem
@export var utility: Utility = Utility

@onready var crafting_list_view: CraftingListView = $CraftingList/ScrollContainer/VBoxContainer

func _ready():
	var resources = utility.load_resources_from_folder("res://resources/loot")
	var loot_items: Array[InventorySystem.ItemQuantity] = []
	for res in resources:
		var item = InventorySystem.ItemQuantity.new()
		item.item = res as LootItem
		item.quantity = 3
		inventory_system.add(item)
		
	var items = inventory_system.get_items()
	crafting_list_view.initialize(items)


# function to spawn a list of crafting materials on this screen
# - items and required amount
# - mystery creature to craft
# 		- node representing the creature
#		- creature name
#		- is_discovered (something seen before by the player?)


# can craft function
# inputs
# list of items from player's inventory
# schematic
# output
# boolean - true if can craft false otherwise

# can meet item craft requirements
# inputs
# item from player's inventory
# schematic entry - material name and quantity
# output
# boolean - true if meet craft requirements; false otherwise
