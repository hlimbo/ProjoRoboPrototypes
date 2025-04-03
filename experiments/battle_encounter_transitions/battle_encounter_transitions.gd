extends Node

# singleton
@export var scene_manager: SceneManager = SceneManager

@export var animation_player: AnimationPlayer
@export var another_player: AnimationPlayer
@export var can_goto_new_scene: bool = false
@onready var buttons: Array[Button] = []

func _ready():
	for child in self.get_children():
		buttons.append(child as Button)
		
	var funcs: Array[Callable] = [
		on_reset_pressed,
		on_scale_pressed,
		on_swirl_pressed,
		on_after_image_pressed,
		on_toggle_new_scene,
	]
	
	for i in range(mini(len(buttons), len(funcs))):
		buttons[i].pressed.connect(funcs[i])
		
	another_player.play("green_move")


func on_scale_pressed():
	animation_player.play("scale_ui_transition")
	
func on_swirl_pressed():
	print("swirl pressed")
	
func on_after_image_pressed():
	print("after image pressed")
	
func on_reset_pressed():
	animation_player.stop()
	
func on_toggle_new_scene():
	can_goto_new_scene = !can_goto_new_scene
	
	if can_goto_new_scene:
		print("going to new scene on transition")
		animation_player.animation_finished.connect(goto_new_scene)
	else:
		print("staying on same scene on transition")
		animation_player.animation_finished.disconnect(goto_new_scene)
		
func goto_new_scene(anim_name: String):
	print("animation finished: ", anim_name)
	scene_manager.change_scene("res://experiments/battle_encounter_transitions/battle_encounter_prototype.tscn")
