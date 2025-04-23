extends Node
class_name SkillSystemDemoController

# dependencies
@export var skills_registry: SkillsRegistry = SkillsRegistry

@export var player1: LiteActor
@export var player2: LiteActor
@export var player1_view: CharacterBlock
@export var player2_view: CharacterBlock
@export var battle_console: ConsoleDemoLoader
@export var stat_deltas: StatDeltas

# operations needed - button press
# * when a skill is casted, 
#    - it should do p1 modifies stat values to p2 and vice versa
#    - it should notify battle console of skill being casted
#    - it should notify stat attributes that its value changed
#	 - it should notify stat deltas of the calculations it made
func load_skills(player: CharacterBlock):
	var data: Array[Resource] = Utility.load_resources_from_folder("res://experiments/skill_system_demo/skill_resources")
	var skills: Array[Skill] = []
	for item in data:
		skills.append(item as Skill)
	
	player.skills_container.load_skills(skills)
	player.skills_container.on_cast_pressed.connect(on_cast_pressed1)

# can be stored in a skill registry of some sort e.g. dictionary 
# whose job is to instantiate new skills during runtime to get processed
var thorny_defense_be: ThornyDefenseBehavior
var goblin_punch_be: GoblinPunchBehavior
var system_shock_be: SystemShockBehavior
var heal_be: HealBehavior
var heal_regen_be: HealRegenBehavior
var burn_be: BurnBehavior
var corkscrew_slash_be: CorkscrewSlashBehavior

# caster, target, skill
func on_cast_pressed1(skill: Skill):
	print("handling skill: ", skill.name)
	
	## Goblin Punch
	#goblin_punch_be = skills_registry.create_skill_behavior(skills_registry.GOBLIN_PUNCH, skill)
	#var raw_deltas: ModifierDelta = goblin_punch_be.accumulate_raw_stat_changes(player1, player2, skill)
	#var net_deltas: ModifierDelta = goblin_punch_be.compute_stat_changes(player2, raw_deltas)
	#goblin_punch_be.apply_stat_changes(player1, player2, net_deltas)
	
	## Thorny Defense
	#thorny_defense_be = skills_registry.create_skill_behavior(skills_registry.THORNY_DEFENSE, skill)
	#thorny_defense_be.bind_status_effects(player1, player1)
	#var raw_deltas: ModifierDelta = thorny_defense_be.accumulate_raw_stat_changes(player1, player1, skill)
	#var net_deltas: ModifierDelta = thorny_defense_be.compute_stat_changes(player1, raw_deltas)
	#thorny_defense_be.apply_stat_changes(player1, player1, net_deltas)
	#thorny_defense_be.start_status_effects(player1, skill)
	
	## System Shock
	#system_shock_be = skills_registry.create_skill_behavior(skills_registry.SYSTEM_SHOCK, skill)
	#system_shock_be.bind_status_effects(player1, player2)
	#var raw_deltas: ModifierDelta = system_shock_be.accumulate_raw_stat_changes(player1, player2, skill)
	#var net_deltas: ModifierDelta = system_shock_be.compute_stat_changes(player2, raw_deltas)
	#system_shock_be.apply_stat_changes(player1, player2, net_deltas)
	#system_shock_be.start_status_effects(player2, skill)
	
	## Heal
	#heal_be = skills_registry.create_skill_behavior(skills_registry.HEAL, skill)
	#var raw_deltas: ModifierDelta = heal_be.accumulate_raw_stat_changes(player1, player2, skill)
	#var net_deltas: ModifierDelta = raw_deltas
	#heal_be.apply_stat_changes(player1, player2, raw_deltas)
	
	## Heal Regen
	#heal_regen_be = skills_registry.create_skill_behavior(skills_registry.HEALTH_REGEN, skill)
	#heal_regen_be.bind_status_effects(player1, player2)
	#var raw_deltas: ModifierDelta = heal_regen_be.accumulate_raw_stat_changes(player1, player2, skill)
	#var net_deltas: ModifierDelta = raw_deltas
	#heal_regen_be.apply_stat_changes(player1, player2, net_deltas)
	#heal_regen_be.start_status_effects(player2, skill)
	
	## Burn
	#burn_be = skills_registry.create_skill_behavior(skills_registry.BURN, skill)
	#burn_be.bind_status_effects(player1, player2)
	#var raw_deltas: ModifierDelta = burn_be.accumulate_raw_stat_changes(player1, player2, skill)
	#var net_deltas: ModifierDelta = burn_be.compute_stat_changes(player2, raw_deltas)
	#burn_be.apply_stat_changes(player1, player2, net_deltas)
	#burn_be.start_status_effects(player2, skill)
	
	## Corkscrew Slash
	corkscrew_slash_be = skills_registry.create_skill_behavior(skills_registry.CORKSCREW_SLASH, skill)
	var raw_deltas: ModifierDelta = corkscrew_slash_be.accumulate_raw_stat_changes(player1, player2, skill)
	var net_deltas: ModifierDelta = corkscrew_slash_be.compute_stat_changes(player2, raw_deltas)
	corkscrew_slash_be.apply_stat_changes(player1, player2, net_deltas)
	
	# update stat deltas
	stat_deltas.set_deltas(net_deltas.hp.get_value(), net_deltas.energy.get_value(), net_deltas.strength.get_value(), net_deltas.toughness.get_value(), net_deltas.speed.get_value())

func update_battle_console(player: CharacterBlock):
	pass


func _ready():
	load_skills(player1_view)
	load_skills(player2_view)
	
	player1.stat_attributes.load_stats([999, 400, 100, 100, 100])
	player2.stat_attributes.load_stats([998, 404, 100, 100, 150])
	
	# connect status effects to display on player_view UI example
	player1.status_effects.on_start_buff.connect(player1_view.status_effect_loader.on_add_buff)
	player1.status_effects.on_end_buff.connect(player1_view.status_effect_loader.on_remove_buff)
	player1.status_effects.on_start_debuff.connect(player1_view.status_effect_loader.on_add_debuff)
	player1.status_effects.on_end_debuff.connect(player1_view.status_effect_loader.on_remove_buff)

	player2.status_effects.on_start_buff.connect(player2_view.status_effect_loader.on_add_buff)
	player2.status_effects.on_end_buff.connect(player2_view.status_effect_loader.on_remove_buff)
	player2.status_effects.on_start_debuff.connect(player2_view.status_effect_loader.on_add_debuff)
	player2.status_effects.on_end_debuff.connect(player2_view.status_effect_loader.on_remove_buff)
