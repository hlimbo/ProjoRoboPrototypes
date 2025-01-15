extends BaseButton

@export var transition_fade: TransitionFade
@export var scene_path: String = "res://scenes/main.tscn"

func _ready() -> void:
	transition_fade.on_finish_tween.connect(change_scene)
	self.pressed.connect(transition_fade.start_transition)

func change_scene():
	var err = get_tree().change_scene_to_file(scene_path)
	if err != OK:
		print_rich("[color=red]changing scene failed. Error code: %d [/color]" % err)
