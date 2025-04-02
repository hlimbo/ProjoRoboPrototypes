extends Button
class_name AtkBtnExperiment

@export var player: AttackExperimentController

func _ready():
	self.pressed.connect(on_attack)
	
func on_attack():
	if is_instance_valid(player):
		player.start_attack()
