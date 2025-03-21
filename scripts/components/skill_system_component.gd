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

func apply_skill_cost(skill_name: String) -> bool:
	if skill_name not in skills:
		return false
		
	assert(is_instance_valid(skill_owner.current_stat_attributes))
	assert(skill_name in skills)
	
	var skill: Skill = skills[skill_name]
	skill_owner.current_stat_attributes.energy.value -= skill.cost
	skill_owner.current_stat_attributes.energy.notify_all()
	return true

func activate_skill(skill_name: String, target: Actor) -> bool:
	if skill_name not in skills:
		return false
	
	assert(is_instance_valid(target))
	assert(is_instance_valid(skill_owner))
	
	var target_skill_system_component: SkillSystemComponent = target.skill_system_component
	var target_status_effects_component: StatusEffectsComponent = target.status_effects_component
	var skill: Skill = skills[skill_name]
	
	# 1. apply status effects to target
	for buff in skill.buffs:
		target_status_effects_component.add_buff(buff)
	for debuff in skill.debuffs:
		target_status_effects_component.add_debuff(debuff)
	
	# 2. apply one-shot stat modifiers based on skill owner's current stat values
	var hp_delta: float = 0
	var strength_delta: float = 0
	var energy_delta: float = 0
	var toughness_delta: float = 0
	var speed_delta: float = 0

	for modifier in skill.modifiers:
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
	
	
	skill_owner.current_stat_attributes.hp.value += hp_delta
	skill_owner.current_stat_attributes.strength.value += strength_delta
	skill_owner.current_stat_attributes.energy.value += energy_delta
	skill_owner.current_stat_attributes.energy.value += toughness_delta
	skill_owner.current_stat_attributes.speed.value += speed_delta
	
	# 3. notify observers of any one-shot stat modifications made
	skill_owner.current_stat_attributes.notify_all()
	
	skills_activation_table[skill_name] = true
	return true

func activate_skill_to_multiple_targets(skill_name: String, targets: Array[Actor]):
	assert(len(targets) > 0)
	for target in targets:
		activate_skill(skill_name, target)

func can_activate_skill(skill_name: String) -> bool:
	assert(is_instance_valid(skill_owner))
	if skill_name not in skills_activation_table:
		return false
		
	var skill: Skill = skills[skill_name]
	if skill.cost > skill_owner.current_stat_attributes.energy.value:
		return false
		
	return skills_activation_table[skill_name]

func deactivate_skill(skill_name: String, caster: Actor, targets: Array[Actor]) -> bool:
	if skill_name not in skills:
		return false
	
	skills_activation_table[skill_name] = false
	var skill: Skill = skills[skill_name]
	
	return true
