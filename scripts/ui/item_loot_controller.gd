extends Control
class_name ItemLootController

@export var utility: Utility = Utility
@export var inventory_system: InventorySystem = InventorySystem

@export var loot_count: int = 10

@onready var selected_item: TextureRect = $ItemsContainer/SelectedItemContainer/SelectedItem
@onready var selected_item_label: Label = $TopContainer/ItemLabelContainer/SelectedItemLabel
@onready var quantity_label: Label = $TopContainer/ItemLabelContainer/QuantityLabel
@onready var description_label: Label = $ItemsContainer/SelectedItemContainer/DescriptionScroll/DescriptionLabel
@onready var item_loot_grid: GridContainer = $ItemsContainer/ScrollContainer/ItemLootGrid
@onready var possible_loot_items: Array[LootItem] = instantiate_loot_items()

var weights: Array[float] = [
	3, # Barked-Plate Armor
	4, # Biofuel Cell
	2, # Charred Circuit
	3, # Cooling Gel
	5, # Flame Module
	2, # Ground Stabilizer
	4, # High Voltage Capacitor
	3, # Hydro Core
	2, # Leaf Sensor
	5, # Magnetic Core
	4, # Molten Core
	1, # Rusted Gear
	3, # Stone Plating
]
	
func generate_loot():
	var loot_items: Dictionary = generate_random_loot(possible_loot_items, loot_count)
	
	# side-effect: add loot items to player inventory
	var items: Array[ItemQuantity] = []
	for loot_item in loot_items:
		var item = ItemQuantity.new()
		item.item = loot_item
		item.quantity = loot_items[loot_item]
		inventory_system.add(item)
	
	create_item_loot_views(loot_items)

func instantiate_loot_items() -> Array[LootItem]:
	var resources: Array[Resource] = Utility.load_resources_from_folder("res://resources/loot")
	
	var loot_items: Array[LootItem] = []
	for res in resources:
		if is_instance_of(res, LootItem):
			loot_items.append(res as LootItem)
	
	return loot_items
	
func generate_random_loot(possible_loot_items: Array[LootItem], loot_count: int) -> Dictionary:
	# key = ItemLoot reference
	# value = quantity
	var loot_items: Dictionary = {}
	for i in range(loot_count):
		var item: LootItem = utility.generate_random_weight(possible_loot_items, weights)
		if item not in loot_items:
			loot_items[item] = 0
			
		loot_items[item] += 1
	
	return loot_items

# loot_items - Dictionary where key is LootItem reference and value is quantity int
func create_item_loot_views(loot_items: Dictionary):
	var unique_item_count: int = len(loot_items)
	var random_loot_icons: Array[Texture2D] = pick_random_placeholder_loot_item_icons(unique_item_count)
	
	# add loot items to grid as children
	var j = 0
	for loot in loot_items:
		var item_loot_view_res: Resource = load("res://nodes/ui/item_loot_icon.tscn")
		var item_loot_view: ItemLootView = item_loot_view_res.instantiate()
		# when this gets added as a child, it calls its _ready() function
		item_loot_grid.add_child(item_loot_view)
		var quantity = loot_items[loot]
		var loot_icon = random_loot_icons[j]
		item_loot_view.init(loot, quantity, loot_icon)
		item_loot_view.on_view.connect(on_click_item)
		
		j += 1

func pick_random_placeholder_loot_item_icons(count: int) -> Array[Texture2D]:
	# load placeholder loot item images
	var resources: Array[Resource] = Utility.load_resources_from_folder("res://assets/kenney_emotes-pack/PNG/Vector/Style 2")
	var images: Array[Texture2D] = []
	for i in range(count):
		var random_index = randi() % len(resources)
		images.append(resources[random_index] as Texture2D)
		# remove icon selected to guarantee unique images
		resources.remove_at(random_index)
		
	return images

func on_click_item(icon: Texture, item_name: String, quantity: int, description: String):
	selected_item.texture = icon
	selected_item_label.text = item_name
	quantity_label.text = "x%d" % quantity
	description_label.text = description
