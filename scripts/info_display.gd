extends Node
class_name InfoDisplay

@onready var name_label: Label = $NameLabel
@onready var hp_label: Label = $HPLabel


@export var avatar: Avatar
@onready var battle_manager: BattleManager

# debugging
#@onready var damage_calculator: IDamageCalculator = BattleSceneManager.damage_calculator
var damage_calculator: IDamageCalculator

#region Debug Settings
# set as export in order to test in isolation
@export_group("Debug Settings")
@export var damage_dealer: Actor
@export var damage_receiver: Actor

@onready var init_stats_btn: Button = $ScrollContainer/DebugMenu/InitStatsBtn
@onready var toggle_dmg_btn: Button = $ScrollContainer/DebugMenu/ToggleDmgBtn
#endregion

func _ready() -> void:
	if avatar:
		name_label.text = avatar.name
		hp_label.text = "HP %d/%d" % [avatar.curr_stats.hp, avatar.initial_stats.hp]

	# for debugging purposes in isolation
	#if damage_calculator:
		#damage_calculator.on_damage_received.connect(on_damage_received)
	
	if toggle_dmg_btn:
		toggle_dmg_btn.pressed.connect(_on_damage_emit)
		
	if init_stats_btn:
		init_stats_btn.pressed.connect(_on_init_fake_stats)
		
	if battle_manager:
		damage_calculator = battle_manager.damage_calculator
		damage_calculator.on_damage_received.connect(on_damage_received)


func on_damage_received(damage_recv: Actor, _damage_dealer: Actor, damage: int) -> void:
	# if the receiver matches the curr avatar, then update its hp
	if damage_recv.avatar == avatar:
		print("%s attacks: %s" % [_damage_dealer.avatar.curr_stats.name, avatar.curr_stats.name])
		hp_label.text = "HP %d/%d" % [avatar.curr_stats.hp, avatar.initial_stats.hp]

#region Test Functions
func update_labels(avatar_: Avatar):
	hp_label.text = "HP %d/%d" % [avatar_.curr_stats.hp, avatar_.initial_stats.hp]
	name_label.text = avatar_.curr_stats.name

func _on_init_fake_stats():
	if damage_dealer:
		damage_dealer.generate_random_stats()
		update_labels(avatar)

func _on_damage_emit():
	if damage_receiver and damage_dealer and damage_calculator:
		var dmg = damage_calculator.calculate_damage(damage_receiver, damage_dealer)
		# apply damage
		damage_receiver.curr_stats.hp = maxi(damage_receiver.curr_stats.hp - dmg, 0)
		damage_calculator.on_damage_received.emit(damage_receiver, damage_dealer)
	else:
		print_rich("[color=red]info_display debug: damage_receiver and damage_dealer null[/color]")
#endregion
