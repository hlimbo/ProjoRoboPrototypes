# used to manage which buffs/debuffs a bot may have during battle
extends Node
class_name StatusEffectsComponent

# This describes what status effects this component currently has
# key is buff name string | value is StatusEffect
@export var buff_tags: Dictionary = {}
# key is buff_name string | value is number of times buff is applied
@export var buff_stacks: Dictionary = {}

# key is debuff name string | value is StatusEffect
@export var debuff_tags: Dictionary = {}
# key is debuff_name string | value is number of times debuff is applied
@export var debuff_stacks: Dictionary = {}

#region signals
# TODO: add data that will manipulate actor's stats
signal on_start_buff(skill_tag: String)
signal on_update_buff(skill_tag: String)
signal on_end_buff(skill_tag: String)

signal on_start_debuff(skill_tag: String)
signal on_update_debuff(skill_tag: String)
signal on_end_debuff(skill_tag: String)
#endregion

func add_buff(status_effect: StatusEffect):
	var buff_tag: String = status_effect.name
	if self.has_buff(buff_tag):
		assert(buff_tag in buff_stacks)
		buff_stacks[buff_tag] += 1
	else:
		buff_tags[buff_tag]
		buff_stacks[buff_tag] = 1

func remove_buff(status_effect: StatusEffect):
	var buff_tag: String = status_effect.name
	if self.has_buff(buff_tag) == false:
		return false
		
	buff_tags.erase(buff_tag)
	buff_stacks.erase(buff_tag)
	return true
	
func add_debuff(status_effect: StatusEffect):
	var debuff_tag: String = status_effect.name
	if self.has_debuff(debuff_tag):
		assert(debuff_tag in debuff_stacks)
		debuff_stacks[debuff_tag] += 1
	else:
		debuff_tags[debuff_tag] = status_effect
		debuff_stacks[debuff_tag] = 1
	
func remove_debuff(status_effect: StatusEffect):
	var debuff_tag: String = status_effect.name
	if self.has_debuff(debuff_tag) == false:
		return false
		
	buff_tags.erase(debuff_tag)
	buff_stacks.erase(debuff_tag)
	return true
	
func has_buff(tag: String) -> bool:
	return buff_tags.has(tag)
	
func has_debuff(tag: String) -> bool:
	return debuff_tags.has(tag)
