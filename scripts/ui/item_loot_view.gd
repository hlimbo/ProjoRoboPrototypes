extends Control
class_name ItemLootView

@onready var icon_rect: TextureRect = $TextureRect
@onready var quantity_label: Label = $QuantityLabel

@export var loot_icon: Texture
@export var loot_name: String
@export var quantity: int
@export var description: String = "This gave me a new idea!"

signal on_view(icon: Texture, item_name: String, quantity: int, description: String)

func _ready() -> void:
	icon_rect.texture = loot_icon
	quantity_label.text = "x%d" % quantity
	self.mouse_entered.connect(on_view_item)
	
func on_view_item():
	on_view.emit(icon_rect.texture, loot_name, quantity, description)
