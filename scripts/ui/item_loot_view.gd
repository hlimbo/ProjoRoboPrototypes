extends Control
class_name ItemLootView

@onready var icon_rect: TextureRect = $TextureRect
@onready var quantity_label: Label = $QuantityLabel

@export var loot_icon: Texture = load("res://assets/kenney_emotes-pack/PNG/Vector/Style 2/emote_swirl.png") as Texture
@export var loot_name: String = "Placeholder Name"
@export var quantity: int = 5
@export var description: String = "This gave me a new idea!"

signal on_view(icon: Texture, item_name: String, quantity: int, description: String)

func _ready() -> void:
	self.mouse_entered.connect(on_view_item)

func on_view_item():
	on_view.emit(icon_rect.texture, loot_name, quantity, description)

func init(item: LootItem, quantity: int, icon: Texture2D):
	self.quantity = quantity
	loot_name = item.item_name
	description = item.description
	
	loot_icon = icon
	icon_rect.texture = loot_icon
	quantity_label.text = "x%d" % quantity
