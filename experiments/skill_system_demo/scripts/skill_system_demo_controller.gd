extends Node
class_name SkillSystemDemoController

# dependencies
@export var status_effect_behavior_manager: StatusEffectBehaviorManager = StatusEffectBehaviorManager
@export var skills_registry: SkillsRegistry = SkillsRegistry

# Turn Simulator
var turn_count_timer: Timer = Timer.new()
var turn_counter: int = 1

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

func accumulate_modifier_deltas(target: LiteActor, modifiers: Array[Modifier]) -> ModifierDelta:
	var output = ModifierDelta.new()
	for mod in modifiers:
		var flat_mod = Utility.convert_percent_to_flat_modifier(target.stat_attributes, mod)
		
		match flat_mod.stat_category_type_target:
			Constants.STAT_HP:
				output.hp.stat_value += flat_mod.get_value()
			Constants.STAT_ENERGY:
				output.energy.stat_value += flat_mod.get_value()
			Constants.STAT_STRENGTH:
				output.strength.stat_value += flat_mod.get_value()
			Constants.STAT_TOUGHNESS:
				output.toughness.stat_value += flat_mod.get_value()
			Constants.STAT_SPEED:
				output.speed.stat_value += flat_mod.get_value()
				
	# convert to absolute values and store sign data in separate variable
	output.hp = Utility.convert_to_absolute_value(output.hp)
	output.energy = Utility.convert_to_absolute_value(output.energy)
	output.strength = Utility.convert_to_absolute_value(output.strength)
	output.toughness = Utility.convert_to_absolute_value(output.toughness)
	output.speed = Utility.convert_to_absolute_value(output.speed)
	
	return output

func accumulate_status_effect_deltas(target: LiteActor, status_effects: Array[StatusEffect]) -> ModifierDelta:
	var output = ModifierDelta.new()
	
	for effect in status_effects:
		for mod in effect.get_modifiers():
			var flat_mod = Utility.convert_percent_to_flat_modifier(target.stat_attributes, mod)
			
			match flat_mod.stat_category_type_target:
				Constants.STAT_HP:
					output.hp.stat_value += flat_mod.get_value()
				Constants.STAT_ENERGY:
					output.energy.stat_value += flat_mod.get_value()
				Constants.STAT_STRENGTH:
					output.strength.stat_value += flat_mod.get_value()
				Constants.STAT_TOUGHNESS:
					output.toughness.stat_value += flat_mod.get_value()
				Constants.STAT_SPEED:
					output.speed.stat_value += flat_mod.get_value()
					
	# convert to absolute values and store sign data in separate variable
	output.hp = Utility.convert_to_absolute_value(output.hp)
	output.energy = Utility.convert_to_absolute_value(output.energy)
	output.strength = Utility.convert_to_absolute_value(output.strength)
	output.toughness = Utility.convert_to_absolute_value(output.toughness)
	output.speed = Utility.convert_to_absolute_value(output.speed)
	
	return output

# the limitation with this design is that it treats ALL 
# skills as something that always applies it to a different target other than the caster
# to support different skill behavior during runtime, one would need to 
# create different button press functions per skill to ensure the proper behavior
# is triggered per skill
func on_cast_pressed1(skill: Skill, caster: LiteActor, target: LiteActor):
	print("handling skill: ", skill.name)
	
	var some = RuleJsonObject.parse_from_json("res://experiments/skill_system_demo/scripts/rules_engine/rule-example.json")
	
	skill_behavior = skills_registry.create_skill_behavior(skill.name, skill)
	
	var raw_deltas: ModifierDelta = skill_behavior.accumulate_raw_stat_changes(caster, target)
	var net_deltas: ModifierDelta = skill_behavior.compute_stat_changes(target, raw_deltas)
	skill_behavior.apply_stat_changes(caster, target, net_deltas)
	
	# Temp code to understand how using the Rule Engine may work in 1 scenario
	var burn_behavior = skill_behavior as BurnBehavior
	if burn_behavior != null:
		var the_rule = Rule.convert_to_rule(skill.rule_set)
		var can_apply_burn_debuff: bool = RuleEngine.evaluate(the_rule)
		if can_apply_burn_debuff:
			print("burn debuff can be applied")
		else:
			print("burn debuff cannot be applied")
	
	# There may or may not be status effects bound to this skill
	# Starting them on cast is optional if no status effects are bound
	if len(skill.buffs) + len(skill.debuffs) > 0:
		skill_behavior.bind_status_effects(caster, target)
		
		var current_time: float = Time.get_ticks_msec()
		var current_turn: int = turn_counter
		var effects: Array[StatusEffect] = []
		effects.append_array(skill.buffs)
		effects.append_array(skill.debuffs)
		for effect in effects:
			status_effect_behavior_manager.start_effect(effect, current_time, current_turn)
		
		skill_behavior.start_status_effects(target)
	
	# combine skill net deltas with status effect deltas to get overall stat changes
	var mod_deltas = ModifierDelta.new()
	
	# accumulate buff and debuff deltas
	var buff_deltas: ModifierDelta = accumulate_status_effect_deltas(target, target.status_effects.get_buffs())
	var debuff_deltas: ModifierDelta = accumulate_status_effect_deltas(target, target.status_effects.get_debuffs())
	
	var final_deltas = ModifierDelta.new()
	final_deltas.hp.stat_value = net_deltas.hp.get_value() + buff_deltas.hp.get_value() + debuff_deltas.hp.get_value()
	final_deltas.energy.stat_value = net_deltas.energy.get_value() + buff_deltas.energy.get_value() + debuff_deltas.energy.get_value()
	final_deltas.strength.stat_value = net_deltas.strength.get_value() + buff_deltas.strength.get_value() + debuff_deltas.strength.get_value()
	final_deltas.toughness.stat_value = net_deltas.toughness.get_value() + buff_deltas.toughness.get_value() + debuff_deltas.toughness.get_value()
	final_deltas.speed.stat_value = net_deltas.speed.get_value() + buff_deltas.speed.get_value() + debuff_deltas.speed.get_value()

	# convert to absolute values
	final_deltas.hp = Utility.convert_to_absolute_value(final_deltas.hp)
	final_deltas.energy = Utility.convert_to_absolute_value(final_deltas.energy)
	final_deltas.strength = Utility.convert_to_absolute_value(final_deltas.strength)
	final_deltas.toughness = Utility.convert_to_absolute_value(final_deltas.toughness)
	final_deltas.speed = Utility.convert_to_absolute_value(final_deltas.speed)

	# update stat deltas - skill modifiers
	stat_deltas.set_deltas(final_deltas.hp.get_value(), final_deltas.energy.get_value(), final_deltas.strength.get_value(), final_deltas.toughness.get_value(), final_deltas.speed.get_value())

	# update battle console text
	var battle_text: String = "%s used %s on %s" % [caster.name, skill.name, target.name]
	battle_console.create_new_message(battle_text)
	

func update_battle_console(player: CharacterBlock):
	pass

func _init():
	turn_count_timer.one_shot = false
	turn_count_timer.wait_time = 2.0
	turn_count_timer.timeout.connect(on_turn_update)

func on_turn_update():
	var current_time: float = Time.get_ticks_msec()
	var current_turn: int = turn_counter
	status_effect_behavior_manager.check_effect_removal(current_time, current_turn)
	turn_counter += 1

func _ready():
	self.add_child(turn_count_timer)
	turn_count_timer.start()
	
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
	
	# whenever a status effect ticks, display the amount of stat value change will be applied
	player1.status_effects.on_second_update_buff.connect(on_buff_update.bind(player1))
	player1.status_effects.on_second_update_debuff.connect(on_debuff_update.bind(player1))
	
	player2.status_effects.on_second_update_buff.connect(on_buff_update.bind(player2))
	player2.status_effects.on_second_update_debuff.connect(on_debuff_update.bind(player2))


func on_buff_update(effect: StatusEffect, target: LiteActor):
	var mod_deltas: ModifierDelta = accumulate_modifier_deltas(target, effect.get_modifiers())
	var string_variables: Array = [target.name, effect.name, mod_deltas.hp.stat_value, mod_deltas.energy.stat_value, mod_deltas.strength.stat_value, mod_deltas.toughness.stat_value, mod_deltas.speed.stat_value]
	var msg: String = "%s has %s.It applies hp: %d, energy: %d, strength: %d, toughness: %d, speed: %d bonus!" % string_variables
	battle_console.create_new_message(msg)
	
func on_debuff_update(effect: StatusEffect, target: LiteActor):
	var mod_deltas: ModifierDelta = accumulate_modifier_deltas(target, effect.get_modifiers())
	var string_variables: Array = [target.name, effect.name, mod_deltas.hp.stat_value, mod_deltas.energy.stat_value, mod_deltas.strength.stat_value, mod_deltas.toughness.stat_value, mod_deltas.speed.stat_value]
	var msg: String = "%s has %s.It applies hp: %d, energy: %d, strength: %d, toughness: %d, speed: %d debuffs!" % string_variables
	battle_console.create_new_message(msg)
