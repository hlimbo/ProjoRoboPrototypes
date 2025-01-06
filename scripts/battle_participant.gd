extends Node
class_name BattleParticipant

var avatar: Avatar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	avatar.on_avatar_flee.connect(on_flee)


func on_flee():
	# remove from scene
	queue_free()
