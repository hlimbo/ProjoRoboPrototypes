extends Node3D
class_name SlashVfxTutorial

@export var play = false

func _physics_process(delta: float) -> void:
	if play:
		$AnimationPlayer.play("slash")
