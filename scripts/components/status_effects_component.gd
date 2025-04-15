# used to manage which buffs/debuffs a bot may have during battle
extends Node
class_name StatusEffectsComponent

# This describes what status effects this component currently has
# key is buff name string | value is StatusEffect
@export var buff_tags: Dictionary = {}
# key is buff_name string | value is number of times buff is applied
@export var buff_stacks: Dictionary = {}
# key is buff_name string | value is float containing the duration
@export var buff_durations: Dictionary = {}

# key is debuff name string | value is StatusEffect
@export var debuff_tags: Dictionary = {}
# key is debuff_name string | value is number of times debuff is applied
@export var debuff_stacks: Dictionary = {}
# key is debuff_name string | value is float containing the duration
@export var debuff_durations: Dictionary = {}

#region signals
signal on_start_buff(effect: StatusEffect)
signal on_update_buff(effect: StatusEffect, stack_count: int)
signal on_process_buff(effect: StatusEffect)
signal on_end_buff(effect: StatusEffect)

signal on_start_debuff(effect: StatusEffect)
signal on_update_debuff(effect: StatusEffect, stack_count: int)
signal on_process_debuff(effect: StatusEffect)
signal on_end_debuff(effect: StatusEffect)
#endregion

func add_buff(status_effect: StatusEffect):
	var buff_tag: String = status_effect.name
	if self.has_buff(buff_tag):
		assert(buff_tag in buff_stacks)
		buff_stacks[buff_tag] += 1
		on_update_buff.emit(status_effect, buff_stacks[buff_tag])
	else:
		buff_tags[buff_tag] = status_effect
		buff_stacks[buff_tag] = 1
		buff_durations[buff_tag] = 0
		on_start_buff.emit(status_effect)

func remove_buff(status_effect: StatusEffect) -> bool:
	var buff_tag: String = status_effect.name
	return self._remove_buff(buff_tag)
	
func _remove_buff(buff_tag: String) -> bool:
	if self.has_buff(buff_tag) == false:
		return false
	
	var effect: StatusEffect = buff_tags[buff_tag]
	buff_tags.erase(buff_tag)
	buff_stacks.erase(buff_tag)
	buff_durations.erase(buff_tag)
	on_end_buff.emit(effect)
	return true
	
func add_debuff(status_effect: StatusEffect):
	var debuff_tag: String = status_effect.name
	if self.has_debuff(debuff_tag):
		assert(debuff_tag in debuff_stacks)
		debuff_stacks[debuff_tag] += 1
		on_update_debuff.emit(status_effect, debuff_stacks[debuff_tag])
	else:
		debuff_tags[debuff_tag] = status_effect
		debuff_stacks[debuff_tag] = 1
		debuff_durations[debuff_tag] = 0
		on_start_debuff.emit(status_effect)
	
func remove_debuff(status_effect: StatusEffect) -> bool:
	var debuff_tag: String = status_effect.name
	return _remove_debuff(debuff_tag)
	
func _remove_debuff(debuff_tag: String) -> bool:
	if self.has_debuff(debuff_tag) == false:
		return false
	
	var debuff: StatusEffect = debuff_tags[debuff_tag]
	debuff_tags.erase(debuff_tag)
	debuff_stacks.erase(debuff_tag)
	debuff_durations.erase(debuff_tag)
	on_end_debuff.emit(debuff)
	return true
	
func has_buff(tag: String) -> bool:
	return buff_tags.has(tag)
	
func has_debuff(tag: String) -> bool:
	return debuff_tags.has(tag)
	
func _process(delta: float):
	var buffs_to_remove: Array[String] = []
	for tag in buff_tags:
		var buff_effect: StatusEffect = buff_tags[tag]
		on_process_buff.emit(buff_effect)
		
		# check duration of buff to end
		assert(tag in buff_durations)
		var curr_buff_duration: float = buff_durations[tag]
		var buff_duration: float = buff_effect.duration
		
		# TODO: count number of turns passed since buff started
		if buff_effect.duration_type == "TURN":
			pass
		elif buff_effect.duration_type == "SECONDS":
			var is_buff_expired: bool = curr_buff_duration >= buff_duration
			if is_buff_expired:
				# mark buff for removal
				buffs_to_remove.append(tag)
			else:
				buff_durations[tag] += delta
				
	for tag in buffs_to_remove:
		self._remove_buff(tag)
	
	var debuffs_to_remove: Array[String] = []
	for tag in debuff_tags:
		var debuff_effect: StatusEffect = debuff_tags[tag]
		on_process_debuff.emit(debuff_effect)
		
		# check duration of debuff to end
		assert(tag in debuff_durations)
		var curr_debuff_duration: float = debuff_durations[tag]
		var debuff_duration: float = debuff_effect.duration
		
		# TODO: count number of turns passed since debuff started
		if debuff_effect.duration_type == "TURN":
			pass
		elif debuff_effect.duration_type == "SECONDS":
			var is_debuff_expired: bool = curr_debuff_duration >= debuff_duration
			if is_debuff_expired:
				debuffs_to_remove.append(tag)
			else:
				debuff_durations[tag] += delta
				
	for tag in debuffs_to_remove:
		self._remove_debuff(tag)
