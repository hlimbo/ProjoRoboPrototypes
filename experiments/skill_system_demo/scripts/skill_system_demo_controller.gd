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
func load_skills(caster_view: CharacterBlock, caster: LiteActor, target: LiteActor):
	var data: Array[Resource] = Utility.load_resources_from_folder("res://experiments/skill_system_demo/skill_resources")
	var skills: Array[Skill] = []
	for item in data:
		skills.append(item as Skill)
	
	caster_view.skills_container.load_skills(skills)
	caster_view.skills_container.on_cast_pressed.connect(on_cast_pressed1.bind(caster, target))

# example of polymorphic skill being casted
# it is scoped in the class instance level to ensure dependencies such as
# status effects and the current skill behavior don't exit scope early
# if it exits scope early, status effect timers may not start or end properly
# Limitation: if player decides to press another skill button, any
# lingering status effects will prematurely end as a new one is used in its place
var skill_behavior: SkillBehavior

# the limitation with this design is that it treats ALL 
# skills as something that always applies it to a different target other than the caster
# to support different skill behavior during runtime, one would need to 
# create different button press functions per skill to ensure the proper behavior
# is triggered per skill
func on_cast_pressed1(skill: Skill, caster: LiteActor, target: LiteActor):
	print("handling skill: ", skill.name)
	
	skill_behavior = skills_registry.create_skill_behavior(skill.name, skill)
	var raw_deltas: ModifierDelta = skill_behavior.accumulate_raw_stat_changes(caster, target)
	var net_deltas: ModifierDelta = skill_behavior.compute_stat_changes(target, raw_deltas)
	skill_behavior.apply_stat_changes(caster, target, net_deltas)
	
	# There may or may not be status effects bound to this skill
	# Starting them on cast is optional if no status effects are bound
	if len(skill.buffs) + len(skill.debuffs) > 0:
		skill_behavior.bind_status_effects(caster, target)
		skill_behavior.start_status_effects(target)
	
	# update stat deltas
	stat_deltas.set_deltas(net_deltas.hp.get_value(), net_deltas.energy.get_value(), net_deltas.strength.get_value(), net_deltas.toughness.get_value(), net_deltas.speed.get_value())
	
	# update battle console text
	var battle_text: String = "%s used %s on %s" % [caster.name, skill.name, target.name]
	battle_console.create_new_message(battle_text)
	

func update_battle_console(player: CharacterBlock):
	pass


func _ready():
	load_skills(player1_view, player1, player2)
	load_skills(player2_view, player2, player1)
	
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
