extends Control
class_name ItemLootController

@onready var selected_item: TextureRect = $ItemsContainer/SelectedItemContainer/SelectedItem
@onready var selected_item_label: Label = $TopContainer/ItemLabelContainer/SelectedItemLabel
@onready var quantity_label: Label = $TopContainer/ItemLabelContainer/QuantityLabel
@onready var description_label: Label = $ItemsContainer/SelectedItemContainer/DescriptionScroll/DescriptionLabel
@onready var item_loot_grid: GridContainer = $ItemsContainer/ScrollContainer/ItemLootGrid

func on_click_item(icon: Texture, item_name: String, quantity: int, description: String):
	selected_item.texture = icon
	selected_item_label.text = item_name
	quantity_label.text = "x%d" % quantity
	description_label.text = description

func _ready() -> void:
	instantiate_loot_items()
	
func instantiate_loot_items():
	var resources: Array[Resource] = Utility.load_resources_from_folder("res://resources/loot")
	
	var loot_items: Array[LootItem] = []
	for res in resources:
		if is_instance_of(res, LootItem):
			loot_items.append(res as LootItem)

	# add loot items to grid as children
	for loot in loot_items:
		var item_loot_view_res: Resource = load("res://nodes/ui/item_loot_icon.tscn")
		var item_loot_view: ItemLootView = item_loot_view_res.instantiate()
		# when this gets added as a child, it calls its _ready() function
		item_loot_grid.add_child(item_loot_view)
		item_loot_view.init(loot)
		item_loot_view.on_view.connect(on_click_item)
