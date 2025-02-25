extends Control
class_name CraftingRowView

@export var utility: Utility = Utility

@export var texture: Texture2D
@export var material_name: String = "Placeholder Item"
@export var quantity_owned: int = 1
@export var quantity_required: int = 10

@onready var material_icon: TextureRect = $HBoxContainer/MaterialIcon
@onready var material_name_label: Label = $HBoxContainer/MaterialNameLabel
@onready var owned_quantity_label: Label = $HBoxContainer/HBoxContainer/OwnedQuantityLabel
@onready var required_quantity_label: Label = $HBoxContainer/HBoxContainer/RequiredQuantityLabel
@onready var divider: Label = $HBoxContainer/HBoxContainer/Divider

func initialize(texture: Texture2D, material_name: String, quantity_owned: int, quantity_required: int):
	self.texture = texture
	self.material_name = material_name
	self.quantity_owned = quantity_owned
	self.quantity_required = quantity_required
	_init_internal()
	update_row_color()

func _init_internal():
	material_icon.texture = self.texture
	material_name_label.text = self.material_name
	owned_quantity_label.text = "%d" % self.quantity_owned
	required_quantity_label.text = "%d" % self.quantity_required

func _ready():
	if utility.is_running_on_own_scene(self):
		_init_internal()
		update_row_color()

func update_row_color():
	if quantity_owned < quantity_required:
		set_text_color(Color.RED)
	else:
		set_text_color(Color.GREEN)

func set_text_color(color: Color):
	owned_quantity_label.self_modulate = color
	divider.self_modulate = color
	required_quantity_label.self_modulate = color

func update_view(inventory_table: Dictionary):
	if material_name in inventory_table:
		quantity_owned = inventory_table[material_name].quantity
	else:
		quantity_owned = 0
	
	owned_quantity_label.text = "%d" % quantity_owned
	update_row_color()
