extends Node

# singleton
@export var scene_manager: SceneManager = SceneManager

# dependencies
@export var animation_player: AnimationPlayer
@export var another_player: AnimationPlayer
@export var viewport_image_loader: ViewportImageLoader
@export var swirl_controller: BaseShaderController
@export var shader_scale_controller: BaseShaderController

@export var can_goto_new_scene: bool = false
@export var effect_duration: float = 3.0; # seconds
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
	
	# used to test the after image shader effect
	another_player.play("green_move")


func on_scale_pressed():
	# animation player method
	# animation_player.play("scale_ui_transition")
	
	# shader method
	shader_scale_controller.play(effect_duration)
	
func on_swirl_pressed():
	assert(swirl_controller != null)
	
	if swirl_controller.is_playing():
		return
		
	swirl_controller.play(effect_duration)
	
func on_after_image_pressed():
	assert(viewport_image_loader != null)
	# don't play the shader if in the middle of being processed
	if viewport_image_loader.is_playing():
		return
		
	print("after image pressed")
	viewport_image_loader.play(effect_duration)
	
func on_reset_pressed():
	animation_player.stop()
	viewport_image_loader.reset()
	swirl_controller.reset()
	shader_scale_controller.reset()
	
func on_toggle_new_scene():
	can_goto_new_scene = !can_goto_new_scene
	
	if can_goto_new_scene:
		print("going to new scene on transition")
		animation_player.animation_finished.connect(goto_new_scene_anim)
		viewport_image_loader.on_play_finished.connect(goto_new_scene)
		swirl_controller.on_play_finished.connect(goto_new_scene)
		shader_scale_controller.on_play_finished.connect(goto_new_scene)
	else:
		print("staying on same scene on transition")
		animation_player.animation_finished.disconnect(goto_new_scene_anim)
		viewport_image_loader.on_play_finished.disconnect(goto_new_scene)
		swirl_controller.on_play_finished.disconnect(goto_new_scene)
		shader_scale_controller.on_play_finished.disconnect(goto_new_scene)
		
func goto_new_scene():
	scene_manager.change_scene("res://experiments/battle_encounter_transitions/battle_encounter_prototype.tscn")

func goto_new_scene_anim(anim_name: String):
	print("animation finished: ", anim_name)
	goto_new_scene()
