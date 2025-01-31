extends Control
class_name BattleReaction

@export var texture: Texture
@export var key_press_label: String

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

func _ready() -> void:
	texture_rect.texture = texture
	label.text  =key_press_label
