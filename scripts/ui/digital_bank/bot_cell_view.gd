extends Control
class_name BotCellView

var bot_name: String
var level: int
var bot_type: String
var energy_type: String
var ordinal: int

@onready var texture_rect: TextureRect = $TextureRect
@onready var button: Button = $Button

@export var is_empty: bool = false

signal on_select(current_cell: BotCellView)

func initialize(bot_name: String, level: int, bot_type: String, energy_type: String):
	self.bot_name = bot_name
	self.level = level
	self.bot_type = bot_type
	self.energy_type = energy_type

func select():
	self.self_modulate = Color.YELLOW
	on_select.emit(self)

func _ready():
	if !is_empty:
		# TODO: load texture data later
		texture_rect.texture = load("res://assets/kenney_emotes-pack/PNG/Vector/Style 2/emote_anger.png")
	else:
		texture_rect.visible = false
		
	button.pressed.connect(select)
	print("I am a part of the following groups: ", self.get_groups())
