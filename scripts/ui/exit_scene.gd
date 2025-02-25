extends BaseButton

@export var scene_manager: SceneManager = SceneManager

@export var transition_fade: TransitionFade
@export var scene_path: String = "res://scenes/main.tscn"

func _ready() -> void:
	transition_fade.on_finish_tween.connect(on_change_scene)
	self.pressed.connect(transition_fade.start_transition)

func on_change_scene():
	scene_manager.change_scene(scene_path)
