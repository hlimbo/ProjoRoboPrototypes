extends Node
class_name CraftingController

# Dependencies
@export var inventory_system: InventorySystem = InventorySystem
@export var utility: Utility = Utility

@onready var crafting_list_view: CraftingListView = $CraftingList/ScrollContainer/VBoxContainer
@onready var craft_button: Button = $CraftingList/VBoxContainer/CraftButton

# placeholder mob - TODO: should dynamically load in the bot's sillouette based on schematic parameters
@onready var mob_1: Node2D = $BotPreviewLayout/mob1
@onready var label: Label = $BotPreviewLayout/Label
var placeholder_creature_name: String = "VoltStrider"

var schematic: Schematic

func _ready():
	# TODO: add functionality to dynamically load a bot schematic based on player selection
	schematic = parse_schematic("res://resources/csv/schematics/voltstrider_schematic.txt")
	
	var inventory_table = inventory_system.get_inventory_table()
	var schematic_table = schematic.get_table()
	crafting_list_view.initialize(inventory_table, schematic_table)
	
	craft_button.pressed.connect(on_craft)
	craft_button.disabled = !can_craft_schematic(schematic_table, inventory_table)

func update_view():
	craft_button.disabled = !can_craft_schematic(schematic.get_table(), inventory_system.get_inventory_table())
	crafting_list_view.update_view(inventory_system.get_inventory_table())

func parse_schematic(file_path: String) -> Schematic:
	var csv_file = FileAccess.open(file_path,FileAccess.READ)
	var is_first_row: bool = true
	var items: Dictionary = {}
	while csv_file.get_position() < csv_file.get_length():
		var line: PackedStringArray = csv_file.get_csv_line("\t")
		
		# skip first row assuming it is a title row
		if is_first_row:
			is_first_row = false
			continue
		
		var schematic_row = SchematicRow.new()
		schematic_row.item_name = line[0]
		schematic_row.quantity = int(line[1])
		items[schematic_row.item_name] = schematic_row
	
	# TODO: dynamically pass in creature names
	return Schematic.new("Voltstrider", items)

# boolean - true if can craft false otherwise
func can_craft_schematic(schematic_table: Dictionary, inventory_table: Dictionary) -> bool:
	for material in schematic_table:
		if material not in inventory_table:
			return false
			
		var inventory_qty: int = inventory_table[material].quantity
		var schematic_qty: int = schematic_table[material].quantity
		if inventory_qty < schematic_qty:
			return false
	
	return true
	
func on_craft():
	var schematic_table: Dictionary = schematic.get_table()
	for material in schematic_table:
		inventory_system.decrease_item_count(material, schematic_table[material].quantity)
	
	update_view()
	
	# TODO(JUICE) - add shader vfx to reveal creation
	var tween = get_tree().create_tween()
	tween.tween_property(mob_1, "modulate", Color.WHITE, 0.75).from(Color.BLACK)
	label.text = placeholder_creature_name
