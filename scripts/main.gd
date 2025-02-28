# This example shows how to do transitions in godot 4.3
extends Node

@export var scene_manager: SceneManager = SceneManager
@onready var transition_layer: TransitionFade = $CanvasLayer/TransitionLayer

@onready var battle_button: Button = $CanvasLayer/VBoxContainer/BattleButton
@onready var craft_button: Button = $CanvasLayer/VBoxContainer/CraftButton
@onready var inventory_button: Button = $CanvasLayer/VBoxContainer/InventoryButton

const BATTLE_SCENE: String = "res://scenes/battle_scene.tscn"
const CRAFT_SCENE: String = "res://nodes/ui/crafting_screen.tscn"
const INVENTORY_SCENE: String = "res://nodes/ui/digital_bank_screen.tscn"

func _ready() -> void:
	battle_button.pressed.connect(on_battle_pressed)
	craft_button.pressed.connect(on_craft_pressed)
	inventory_button.pressed.connect(on_inventory_pressed)

func begin_transition(scene_path: String):
	transition_layer.start_transition()
	transition_layer.on_finish_tween.connect(func(): scene_manager.change_scene(scene_path))

func on_battle_pressed():
	begin_transition(BATTLE_SCENE)
	
func on_craft_pressed():
	begin_transition(CRAFT_SCENE)

func on_inventory_pressed():
	begin_transition(INVENTORY_SCENE)
