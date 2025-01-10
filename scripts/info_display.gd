extends Node
class_name InfoDisplay

@onready var name_label: Label = $NameLabel
@onready var hp_label: Label = $HPLabel

@onready var avatar: Avatar
@onready var battle_manager: BattleManager

func _ready() -> void:
	if avatar:
		name_label.text = avatar.name
		hp_label.text = "HP %d/%d" % [avatar.curr_stats.hp, avatar.initial_stats.hp]
	
	if battle_manager:
		battle_manager.damage_calculator.on_damage_received.connect(_on_damage_received)
	else:
		print_rich("[color=red]no battle manager ref found[/color]")


func _on_damage_received(damage_receiver: Avatar, damage_dealer: Avatar) -> void:
	# if the receiver matches the curr avatar, then update its hp
	if damage_receiver == avatar:
		hp_label.text = "HP %d/%d" % [damage_receiver.curr_stats.hp, damage_receiver.initial_stats.hp]
