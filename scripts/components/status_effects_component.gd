# used to manage which buffs/debuffs a bot may have during battle
extends Node
class_name StatusEffectsComponent

# This describes what status effects this component currently has
# key is buff name string | value is StatusEffect
@export var buff_tags: Dictionary = {}
# key is buff_name string | value is number of times buff is applied
@export var buff_stacks: Dictionary = {}
# key is buff_name string | value is float containing the current duration
# to know the duration_type of the value, lookup the buff in buff_tags
@export var buff_durations: Dictionary = {}

# key is debuff name string | value is StatusEffect
@export var debuff_tags: Dictionary = {}
# key is debuff_name string | value is number of times debuff is applied
@export var debuff_stacks: Dictionary = {}
# key is debuff_name string | value is float containing the current duration
# to know the duration_type of the value, lookup the debuff in debuff_tags
@export var debuff_durations: Dictionary = {}
# used to control if timers and turn counters should resume or be paused
@export var is_paused: bool = false

# this is used to keep track of all active buffs / debuffs occurring every second
var second_interval_timer: Timer

var counter: int = 0

#region signals
signal on_start_buff(effect: StatusEffect)
signal on_update_buff(effect: StatusEffect, stack_count: int)
signal on_second_update_buff(effect: StatusEffect)
signal on_turn_update_buff(effect: StatusEffect)
signal on_end_buff(effect: StatusEffect)

signal on_start_debuff(effect: StatusEffect)
signal on_update_debuff(effect: StatusEffect, stack_count: int)
signal on_second_update_debuff(effect: StatusEffect)
signal on_turn_update_debuff(effect: StatusEffect)
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

	# run the timer when at least 1 buff is active
	if second_interval_timer.is_stopped():
		second_interval_timer.start()
		counter = 0

func remove_buff(status_effect: StatusEffect) -> bool:
	var buff_tag: String = status_effect.name
	return self._remove_buff(buff_tag)
	
func _remove_buff(buff_tag: String) -> bool:
	if self.has_buff(buff_tag) == false:
		return false
	
	var effect: StatusEffect = buff_tags[buff_tag]
	on_end_buff.emit(effect)
	
	buff_tags.erase(buff_tag)
	buff_stacks.erase(buff_tag)
	buff_durations.erase(buff_tag)
	
	# stop timer if all buffs and debuffs grouped by SECONDS are inactive
	var buffs_by_seconds_count: int = buff_tags.values().filter(func(buff: StatusEffect): return buff.duration_type == "SECONDS").size()
	var debuffs_by_seconds_count: int = debuff_tags.values().filter(func(debuff: StatusEffect): return debuff.duration_type == "SECONDS").size()
	var effect_count: int = buffs_by_seconds_count + debuffs_by_seconds_count
	if effect_count == 0:
		second_interval_timer.stop()
	
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
		
	# run the timer when at least 1 debuff is active
	if second_interval_timer.is_stopped():
		second_interval_timer.start()
		counter = 0
	
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
	
	# stop timer if all buffs and debuffs grouped by SECONDS are inactive
	var buffs_by_seconds_count: int = buff_tags.values().filter(func(buff: StatusEffect): return buff.duration_type == "SECONDS").size()
	var debuffs_by_seconds_count: int = debuff_tags.values().filter(func(debuff: StatusEffect): return debuff.duration_type == "SECONDS").size()
	var effect_count: int = buffs_by_seconds_count + debuffs_by_seconds_count
	if effect_count == 0:
		second_interval_timer.stop()
	
	return true
	
func has_buff(tag: String) -> bool:
	return buff_tags.has(tag)
	
func has_debuff(tag: String) -> bool:
	return debuff_tags.has(tag)

# status_effects: key = string tag | value = StatusEffect
# durations: key = string tag | value = duration value float
# on_update: signal whose function signature accepts a StatusEffect parameter
# time_step: used to advance time where its lower_bound > 0
# returns a list of status effect tags that are expired
func _update_status_effect_timer(status_effects: Dictionary, durations: Dictionary, duration_type: String, on_update: Signal, time_step: float) -> PackedStringArray:
	var expired_tags: PackedStringArray = []
	
	# filter by duration type 
	var effect_tags: PackedStringArray = []
	for tag in status_effects:
		var status_effect: StatusEffect = status_effects[tag]
		if status_effect.duration_type == duration_type:
			effect_tags.append(tag)
	
	for tag in effect_tags:
		assert(tag in status_effects)
		assert(tag in durations)
		
		var effect: StatusEffect = status_effects[tag]
		var curr_duration: float = durations[tag]
		var duration: float = effect.duration
		var is_expired: bool = curr_duration >= duration
		if is_expired:
			expired_tags.append(tag)
		else:
			durations[tag] += time_step
			on_update.emit(effect)
			
	return expired_tags

func update_status_effects_turn_counts():
	if is_paused:
		return
	
	var duration_type: String = "TURN"
	var time_step: float = 1.0
	var buffs_to_remove: PackedStringArray = _update_status_effect_timer(buff_tags, buff_durations, duration_type, on_turn_update_buff, time_step)
	var debuffs_to_remove: PackedStringArray = _update_status_effect_timer(debuff_tags, debuff_durations, duration_type, on_turn_update_debuff, time_step)
	
	for tag in buffs_to_remove:
		_remove_buff(tag)
	for tag in debuffs_to_remove:
		_remove_debuff(tag)

func on_second_interval_timeout():
	print("time counter: ", counter)
	counter += 1
	var time_step: float = 1.0
	var duration_type: String = "SECONDS"
	var expired_buff_tags: PackedStringArray = _update_status_effect_timer(buff_tags, buff_durations, duration_type, on_second_update_buff, time_step)
	var expired_debuff_tags: PackedStringArray = _update_status_effect_timer(debuff_tags, debuff_durations, duration_type, on_second_update_debuff, time_step)
	
	for tag in expired_buff_tags:
		_remove_buff(tag)
	for tag in expired_debuff_tags:
		_remove_debuff(tag)

func enable():
	is_paused = false
	second_interval_timer.paused = is_paused
	
func disable():
	is_paused = true
	second_interval_timer.paused = is_paused

func get_buffs() -> Array[StatusEffect]:
	var buffs: Array[StatusEffect]
	buffs.assign(buff_tags.values())
	return buffs
	
func get_debuffs() -> Array[StatusEffect]:
	var debuffs: Array[StatusEffect]
	debuffs.assign(debuff_tags.values())
	return debuffs

func _init():
	second_interval_timer = Timer.new()
	second_interval_timer.one_shot = false
	second_interval_timer.wait_time = 1.0 # second
	second_interval_timer.timeout.connect(on_second_interval_timeout)
	# add timer to scene tree to activate timer
	add_child(second_interval_timer)
