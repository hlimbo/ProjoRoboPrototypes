extends Node
class_name SkillSystemComponent

# This describes what buffs/debuffs this component currently has
@export var buff_tags: Array[String] = []
@export var debuff_tags: Array[String] = []

# key - skill name - String
# value - Skill
@export var skills: Dictionary = {}

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

func add_skill(skill: Skill) -> bool:
	return false
	
func remove_skill_by_name(skill_name: String) -> bool:
	return false
	
func remove_skill(skill: Skill) -> bool:
	return false

# remove all skills
func clear() -> bool:
	return false
	
func activate_skill(skill_name: String) -> bool:
	return false
	
func add_buff_tag(buff_tag: String) -> bool:
	return false
	
func remove_buff_tag(buff_tag: String) -> bool:
	return false
	
func add_debuff_tag(debuff_tag: String) -> bool:
	return false
	
func remove_debuff_tag(debuff_tag: String) -> bool:
	return false
