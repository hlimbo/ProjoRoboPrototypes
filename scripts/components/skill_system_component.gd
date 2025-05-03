extends Node
class_name SkillSystemComponent

# key - skill name - String
# value - Skill
@export var skills: Dictionary = {}
# key - skill name - String
# value - boolean - true if activated; false otherwise
@export var skills_activation_table: Dictionary = {}
@export var skill_owner: Actor

# TODO: pass in path to load in skills
func load_skills():
	var skill_reader = SkillsCsvReader.new()
	var skill_datum: Array = skill_reader.read_csv_file("res://resources/csv/skills/junk_goblin_skills_csv.txt", "\t")
	
	for skill_data in skill_datum:
		var skill = skill_data as Skill
		assert(is_instance_valid(skill))
		skills[skill.name] = skill

func add_skill(skill: Skill) -> bool:
	if skill.name in skills:
		return false
	
	skills[skill.name] = skill
	return true
	
func remove_skill_by_name(skill_name: String) -> bool:
	if skill_name not in skills:
		return false
		
	return skills.erase(skill_name)
	
func remove_skill(skill: Skill) -> bool:
	if skill.name not in skills:
		return false
	
	return skills.erase(skill.name)

# remove all skills
func clear() -> bool:
	skills.clear()
	return skills.is_empty()

# TODO: switch back to returning a bool instead of Array[float] e.g. raw stat values
func activate_skill(skill_name: String, target: Actor) -> Array[float]:
	if skill_name not in skills:
		return []
	
	assert(is_instance_valid(target))
	assert(is_instance_valid(skill_owner))
	
	var target_status_effects_component: StatusEffectsComponent = target.status_effects_component
	var skill: Skill = skills[skill_name]
	
	# 1. apply status effects to target
	for buff in skill.buffs:
		target_status_effects_component.add_buff(buff)
	for debuff in skill.debuffs:
		target_status_effects_component.add_debuff(debuff)
	
	# 2. apply one-shot stat modifiers based on skill owner's current stat values
	# TODO: FEEDBACK: this logic may need to be offloaded into a signal so other classes can
	# compute stat values someplace else....
	# helps with separation of concerns and prevents shoe-horning a single aspect of code to be
	# this limiting
	# all this function should really be doing is:
	# 1. applying buffs and debuffs to the target actor
	# 2. notifying of other systems that the skill has been activated
	# 3. turning on this skill by looking up in a dictionary and setting its flag to true
	var hp_delta: float = 0
	var strength_delta: float = 0
	var energy_delta: float = 0
	var toughness_delta: float = 0
	var speed_delta: float = 0

	for modifier in skill.get_modifiers():
		var flat_modifier: Modifier = Utility.convert_percent_to_flat_modifier(skill_owner.current_stat_attributes, modifier)
		
		match modifier.stat_category_type_target:
			Constants.STAT_HP:
				hp_delta += flat_modifier.stat_value
			Constants.STAT_STRENGTH:
				strength_delta += flat_modifier.stat_value
			Constants.STAT_ENERGY:
				energy_delta += flat_modifier.stat_value
			Constants.STAT_TOUGHNESS:
				toughness_delta += flat_modifier.stat_value
			Constants.STAT_SPEED:
				speed_delta += flat_modifier.stat_value
	
	# 2a. calculate net values -- these formulas can be complex!
	# add because hp_delta is negative on dmg modifiers
	var net_hp_delta: float = hp_delta + target.current_stat_attributes.toughness.value
	
	target.current_stat_attributes.hp.value += net_hp_delta
	target.current_stat_attributes.strength.value += strength_delta
	target.current_stat_attributes.energy.value += energy_delta
	target.current_stat_attributes.toughness.value += toughness_delta
	target.current_stat_attributes.speed.value += speed_delta
	
	# 3. notify observers of any one-shot stat modifications made
	target.current_stat_attributes.notify_all()
	
	skills_activation_table[skill_name] = true
	return [net_hp_delta, strength_delta, energy_delta, toughness_delta, speed_delta]

func activate_skill_to_multiple_targets(skill_name: String, targets: Array[Actor]):
	assert(len(targets) > 0)
	for target in targets:
		activate_skill(skill_name, target)

func can_activate_skill(skill_name: String) -> bool:
	assert(is_instance_valid(skill_owner))
	if skill_name not in skills_activation_table:
		return false
		
	var skill: Skill = skills[skill_name]
	if skill.get_modifier("energy-cost").stat_value > skill_owner.current_stat_attributes.energy.value:
		return false
		
	return skills_activation_table[skill_name]

func deactivate_skill(skill_name: String, caster: Actor, targets: Array[Actor]) -> bool:
	if skill_name not in skills:
		return false
	
	skills_activation_table[skill_name] = false
	var skill: Skill = skills[skill_name]
	
	return true

# TODO: remove as skill_system_component is only responsible for turning on/off skills
# the behaviour to apply specific stat values through modifiers should be handled somewhere else not here
# this is done to quickly verify how some of the Skill Ideas Richie had would work out
func thorny_defense(target: Actor):
	var skill_name: String = "Goblin Punch"
	assert(skill_name in skills)
	var skill: Skill = skills[skill_name]
	var target_status_effects_component: StatusEffectsComponent = target.status_effects_component
	
	for buff in skill.buffs:
		target_status_effects_component.add_buff(buff)
	
	skills_activation_table[skill_name] = true
