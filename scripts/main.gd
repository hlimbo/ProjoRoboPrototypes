# This example shows how to do transitions in godot 4.3
extends Node

@export var scene_manager: SceneManager = SceneManager
@onready var transition_layer: TransitionFade = $CanvasLayer/TransitionLayer

@onready var battle_button: Button = $CanvasLayer/VBoxContainer/BattleButton
@onready var craft_button: Button = $CanvasLayer/VBoxContainer/CraftButton

const BATTLE_SCENE: String = "res://scenes/battle_scene.tscn"
const CRAFT_SCENE: String = "res://nodes/ui/crafting_screen.tscn"

func _ready() -> void:
	battle_button.pressed.connect(on_battle_pressed)
	craft_button.pressed.connect(on_craft_pressed)

func on_battle_pressed():
	transition_layer.start_transition()
	transition_layer.on_finish_tween.connect(func(): scene_manager.change_scene(BATTLE_SCENE))
	
func on_craft_pressed():
	transition_layer.start_transition()
	transition_layer.on_finish_tween.connect(func(): scene_manager.change_scene(CRAFT_SCENE))
