extends Control
class_name BotDescriptionView

@export var utility: Utility = Utility

@export var bot_name: String
@export var level: int
@export var bot_type: String
@export var energy_type: String

@onready var name_label: Label = $VBoxContainer/HBoxContainer/NameLabel
@onready var level_label: Label = $VBoxContainer/HBoxContainer/LevelLabel
@onready var type_label: Label = $VBoxContainer/HBoxContainer2/HBoxContainer/TypeLabel
@onready var energy_label: Label = $VBoxContainer/HBoxContainer2/HBoxContainer2/EnergyLabel

@onready var type_icon: TextureRect = $VBoxContainer/HBoxContainer2/HBoxContainer/TypeIcon
@onready var energy_icon: TextureRect = $VBoxContainer/HBoxContainer2/HBoxContainer2/EnergyIcon


# key = resource name - string
# value = AtlasTexture
var bot_icons: Dictionary = {}
var energy_icons: Dictionary = {}

func _ready():
	var res1: Array = utility.load_resources_from_folder("res://resources/placeholder_art/bot_icons")
	var res2: Array = utility.load_resources_from_folder("res://resources/placeholder_art/energy_icons")
	
	for res in res1:
		var icon: AtlasTexture = res as AtlasTexture
		bot_icons[icon.resource_name] = icon
		
	for res in res2:
		var icon: AtlasTexture = res as AtlasTexture
		energy_icons[icon.resource_name] = icon

func initialize(bot_name: String, level: int, bot_type: String, energy_type: String):
	self.bot_name = bot_name
	self.level = level
	self.bot_type = bot_type
	self.energy_type = energy_type
	
	name_label.text = bot_name
	level_label.text = "Lv. %d" % level
	type_label.text = bot_type
	energy_label.text = energy_type
	
	type_icon.texture = bot_icons[bot_type.to_lower()]
	energy_icon.texture = energy_icons[energy_type.to_lower()]
