extends Control
class_name CraftingListView

@export var row_view: Resource = preload("res://nodes/ui/crafting/crafting_row.tscn")
@export var placeholder_texture: Texture2D = preload("res://assets/kenney_emotes-pack/PNG/Vector/Style 2/emote_alert.png")
var rows: Array[CraftingRowView] = []

# items - items player owns where key = item_name string | value = ItemQuantity
# required_materials - items required to craft where key = item_name string | value = SchematicRow
func initialize(items: Dictionary, required_materials: Dictionary):
	for material in required_materials:
		var row: CraftingRowView = row_view.instantiate()
		add_child(row) # this calls row's _ready() function when added to this node
		var required_amt: int = required_materials[material].quantity
		var owned_amt: int = items[material].quantity if items.get(material) != null else 0 
		row.initialize(placeholder_texture, material, owned_amt, required_amt)
		rows.append(row)

func update_view(inventory_table: Dictionary):
	for row in rows:
		row.update_view(inventory_table)
