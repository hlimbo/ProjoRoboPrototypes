extends Node
class_name SkillSystemComponent

# This describes what buffs/debuffs this component currently has
@export var buff_tags: Array[String] = []
@export var debuff_tags: Array[String] = []

# key - skill name - String
# value - Skill
@export var skills: Dictionary = {}
# key - skill name - String
# value - boolean - true if activated; false otherwise
@export var skills_activation_table = {}

#region signals

signal on_start_skill(skill: Skill, source: Actor, targets: Array[Actor])
signal on_end_skill(skill: Skill, source: Actor, targets: Array[Actor])

# TODO: add data that will manipulate actor's stats
signal on_start_buff(skill_tag: String)
signal on_update_buff(skill_tag: String)
signal on_end_buff(skill_tag: String)

signal on_start_debuff(skill_tag: String)
signal on_update_debuff(skill_tag: String)
signal on_end_debuff(skill_tag: String)

#endregion

##region Godot standard callback functions
#
## TODO: should this manage skills being processed per tick, it would need to know about the actors involved
#func _process(delta: float):
	#var active_array: Array = skills.values().filter(func(s: Skill): return skills_activation_table[s.name] == true)
	#var active_skills: Array[Skill] = []
	#for s in active_array:
		#active_skills.append(s as Skill)
	#
	##for skill in active_skills:
	##	skill
	#
##endregion

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
	
func activate_skill(skill_name: String, caster: Actor, targets: Array[Actor]) -> bool:
	if skill_name not in skills:
		return false
	
	skills_activation_table[skill_name] = true
	var skill: Skill = skills[skill_name]
	on_start_skill.emit(skill, caster, targets)
	
	return true
	
func can_activate_skill(skill_name: String) -> bool:
	if skill_name not in skills_activation_table:
		return false
		
	return skills_activation_table[skill_name]

func deactivate_skill(skill_name: String, caster: Actor, targets: Array[Actor]) -> bool:
	if skill_name not in skills:
		return false
	
	skills_activation_table[skill_name] = false
	var skill: Skill = skills[skill_name]
	on_end_skill.emit(skill, caster, targets)
	
	return true

func add_buff_tag(buff_tag: String) -> bool:
	if buff_tags.has(buff_tag):
		return false
		
	buff_tags.append(buff_tag)
	return true
	
func remove_buff_tag(buff_tag: String) -> bool:
	if not buff_tags.has(buff_tag):
		return false
		
	buff_tags.erase(buff_tag)
	return true
	
func add_debuff_tag(debuff_tag: String) -> bool:
	if debuff_tags.has(debuff_tag):
		return false
	
	debuff_tags.append(debuff_tag)
	return true
	
func remove_debuff_tag(debuff_tag: String) -> bool:
	if not debuff_tags.has(debuff_tag):
		return false
		
	debuff_tags.erase(debuff_tag)
	return true
	
func has_buff(tag: String) -> bool:
	return buff_tags.has(tag)
	
func has_debuff(tag: String) -> bool:
	return debuff_tags.has(tag)
