extends Node

# singleton
@export var scene_manager: SceneManager = SceneManager

# dependencies
@export var animation_player: AnimationPlayer
@export var another_player: AnimationPlayer
@export var viewport_image_loader: ViewportImageLoader

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
	assert(viewport_image_loader != null)
	# don't play the shader if in the middle of being processed
	if viewport_image_loader.is_shader_playing():
		return
		
	print("after image pressed")
	viewport_image_loader.visible = true
	await viewport_image_loader.capture_image()
	viewport_image_loader.play_shader(3.0)
	
func on_reset_pressed():
	animation_player.stop()
	viewport_image_loader.reset_shader()
	
func on_toggle_new_scene():
	can_goto_new_scene = !can_goto_new_scene
	
	if can_goto_new_scene:
		print("going to new scene on transition")
		animation_player.animation_finished.connect(goto_new_scene_anim)
		viewport_image_loader.on_shader_playing_finished.connect(goto_new_scene)
	else:
		print("staying on same scene on transition")
		animation_player.animation_finished.disconnect(goto_new_scene_anim)
		viewport_image_loader.on_shader_playing_finished.disconnect(goto_new_scene)
		
func goto_new_scene():
	scene_manager.change_scene("res://experiments/battle_encounter_transitions/battle_encounter_prototype.tscn")

func goto_new_scene_anim(anim_name: String):
	print("animation finished: ", anim_name)
	goto_new_scene()
