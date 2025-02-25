extends Control
class_name CraftingListView

@export var row_view: Resource = preload("res://nodes/ui/crafting/crafting_row.tscn")
@export var placeholder_texture: Texture2D = preload("res://assets/kenney_emotes-pack/PNG/Vector/Style 2/emote_alert.png")

func initialize(items: Array[InventorySystem.ItemQuantity]):
	for item in items:
		var row: CraftingRowView = row_view.instantiate()
		add_child(row) # this calls row's _ready() function when added to this node
		row.initialize(placeholder_texture, item.item.item_name, item.quantity, 10)
