extends Button

# singleton
@export var scene_manager: SceneManager = SceneManager

func _ready():
	self.pressed.connect(func():
		scene_manager.change_scene("res://experiments/battle_encounter_transitions/overworld_encounter_prototype.tscn")
	)
