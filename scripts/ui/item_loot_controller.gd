extends Control
class_name ItemLootController

@onready var selected_item: TextureRect = $ItemsContainer/SelectedItemContainer/SelectedItem
@onready var selected_item_label: Label = $TopContainer/ItemLabelContainer/SelectedItemLabel
@onready var quantity_label: Label = $TopContainer/ItemLabelContainer/QuantityLabel
@onready var description_label: Label = $ItemsContainer/SelectedItemContainer/DescriptionScroll/DescriptionLabel
@onready var item_loot_grid: GridContainer = $ItemsContainer/ScrollContainer/ItemLootGrid
@onready var items: Array[Node] = item_loot_grid.get_children()
var loot_items: Array[ItemLootView] = []

func on_click_item(icon: Texture, item_name: String, quantity: int, description: String):
	selected_item.texture = icon
	selected_item_label.text = item_name
	quantity_label.text = "x%d" % quantity
	description_label.text = description

func _ready() -> void:
	loot_items.append_array(items as Array[ItemLootView])
	for loot in loot_items:
		loot.on_view.connect(on_click_item)
