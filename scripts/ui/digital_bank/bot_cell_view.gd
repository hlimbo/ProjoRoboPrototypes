extends Control
class_name BotCellView

var bot_name: String
var level: int
var bot_type: String
var energy_type: String
var ordinal: int
var avatar_icon: Texture2D

@onready var texture_rect: TextureRect = $TextureRect
@onready var button: Button = $Button

@export var is_empty: bool = false

signal on_select(current_cell: BotCellView)
signal on_deselect(current_cell: BotCellView)

func initialize(bot_name: String, level: int, bot_type: String, energy_type: String, avatar_icon: Texture2D):
	self.bot_name = bot_name
	self.level = level
	self.bot_type = bot_type
	self.energy_type = energy_type
	self.avatar_icon = avatar_icon

func select():
	self_modulate = Color.YELLOW
	on_select.emit(self)

func deselect():
	self_modulate = Color.WHITE
	on_deselect.emit(self)

func _ready():
	if is_empty:
		texture_rect.visible = false
	else:
		texture_rect.texture = avatar_icon
	
	button.pressed.connect(on_button_pressed)
	
func on_button_pressed():
	if self_modulate == Color.YELLOW:
		deselect()
	else:
		select() 
