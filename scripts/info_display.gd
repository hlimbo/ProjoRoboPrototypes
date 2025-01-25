extends Node
class_name InfoDisplay

@onready var name_label: Label = $NameLabel
@onready var hp_label: Label = $HPLabel


# @onready var avatar: Avatar
@export var avatar: Avatar
@onready var battle_manager: BattleManager

@onready var damage_calculator: IDamageCalculator = BattleSceneManager.damage_calculator


#region Debug Settings
# set as export in order to test in isolation
@export_group("Debug Settings")
@export var damage_dealer: Avatar
@export var damage_receiver: Avatar

@onready var init_stats_btn: Button = $ScrollContainer/DebugMenu/InitStatsBtn
@onready var toggle_dmg_btn: Button = $ScrollContainer/DebugMenu/ToggleDmgBtn
#endregion

func _ready() -> void:
	if avatar:
		name_label.text = avatar.name
		hp_label.text = "HP %d/%d" % [avatar.curr_stats.hp, avatar.initial_stats.hp]

	if damage_calculator:
		damage_calculator.on_damage_received.connect(_on_damage_received)
	
	if battle_manager:
		battle_manager.damage_calculator.on_damage_received.connect(_on_damage_received)
	else:
		print_rich("[color=red]no battle manager ref found[/color]")
	
	if toggle_dmg_btn:
		toggle_dmg_btn.pressed.connect(_on_damage_emit)
		
	if init_stats_btn:
		init_stats_btn.pressed.connect(_on_init_fake_stats)


func _on_damage_received(damage_recv: Avatar, _damage_dealer: Avatar) -> void:	
	# if the receiver matches the curr avatar, then update its hp
	if damage_recv == avatar:
		print("%s attacks: %s " % [_damage_dealer.curr_stats.name, damage_recv.curr_stats.name])
		hp_label.text = "HP %d/%d" % [damage_recv.curr_stats.hp, damage_recv.initial_stats.hp]

#region Test Functions
func update_labels(avatar_: Avatar):
	hp_label.text = "HP %d/%d" % [avatar_.curr_stats.hp, avatar_.initial_stats.hp]
	name_label.text = avatar_.curr_stats.name

func _on_init_fake_stats():
	if damage_dealer:
		damage_dealer.generate_random_stats()
		update_labels(damage_dealer)

func _on_damage_emit():
	if damage_receiver and damage_dealer:
		var dmg = damage_calculator.calculate_damage(damage_receiver, damage_dealer)
		# apply damage
		damage_receiver.curr_stats.hp = maxi(damage_receiver.curr_stats.hp - dmg, 0)
		damage_calculator.on_damage_received.emit(damage_receiver, damage_dealer)
	else:
		print_rich("[color=red]info_display debug: damage_receiver and damage_dealer null[/color]")
#endregion
