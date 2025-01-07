extends Node
class_name InfoDisplay

@onready var name_label: Label = $NameLabel
@onready var hp_label: Label = $HPLabel
@onready var avatar: Avatar

func _ready() -> void:
	if avatar:
		name_label.text = avatar.name
		hp_label.text = "HP %d/%d" % [avatar.curr_stats.hp, avatar.initial_stats.hp]
		
		avatar.on_damage_received.connect(_on_damage_received)


func _on_damage_received(damage_receiver: Avatar, damage_dealer: Avatar) -> void:
	print("info display called")
	hp_label.text = "HP %d/%d" % [damage_receiver.curr_stats.hp, damage_receiver.initial_stats.hp]
