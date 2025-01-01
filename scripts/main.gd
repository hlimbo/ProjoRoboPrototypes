# This example shows how to do transitions in godot 4.3
extends Node

@onready var battle_button: Button = $CanvasLayer/VBoxContainer/BattleButton
@onready var transition_rect: ColorRect = $CanvasLayer/TransitionRect

const BATTLE_SCENE: String = "res://scenes/battle_scene.tscn"

func _ready() -> void:
	transition_rect.visible = false
	battle_button.pressed.connect(transition_to_scene)

func transition_to_scene():
	transition_rect.visible = true
	var tween: Tween = get_tree().create_tween()
	# set tween alpha from 0 alpha to 1 alpha on the modulate property's alpha component
	tween.tween_property(transition_rect, "modulate:a", 1, 0.25).from(0)
	tween.finished.connect(on_battle_pressed)

func on_battle_pressed() -> void:
	var err = get_tree().change_scene_to_file(BATTLE_SCENE)
	if err != OK:
		print_rich("[color=red]changing scene failed. Error code: %d [/color]" % err)
