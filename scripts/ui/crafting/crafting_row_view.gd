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


func initialize(texture: Texture2D, material_name: String, quantity_owned: int, quantity_required: int):
	self.texture = texture
	self.material_name = material_name
	self.quantity_owned = quantity_owned
	self.quantity_required = quantity_required
	_init_internal()

func _init_internal():
	material_icon.texture = self.texture
	material_name_label.text = self.material_name
	owned_quantity_label.text = "%d" % self.quantity_owned
	required_quantity_label.text = "%d" % self.quantity_required

func _ready():
	if utility.is_running_on_own_scene(self):
		_init_internal()
