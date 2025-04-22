# Base class that is used as a framework to help define
# how different kinds of status effects should behave
extends RefCounted
class_name StatusEffectBehavior

# used to identify which status_effect to handle
var status_effect_name: String
var target: LiteActor

func _notification(what: int):
	if what == NOTIFICATION_PREDELETE:
		print("StatusEffectBehavior: %s is going to be deleted" % status_effect_name)

func initialize(status_effect: StatusEffect, _target: LiteActor):
	status_effect_name = status_effect.name
	target = _target
	var status_effects_component = target.status_effects
	
	# One Shot Status Effects can be defined in on_start callback
	if status_effect.effect_type == "positive":
		status_effects_component.on_start_buff.connect(on_start)
		status_effects_component.on_end_buff.connect(on_end)
		
	elif status_effect.effect_type == "negative":
		status_effects_component.on_start_debuff.connect(on_start)
		status_effects_component.on_end_debuff.connect(on_end)
	
	if status_effect.duration_type == "TURN":
		if status_effect.effect_type == "positive":
			status_effects_component.on_turn_update_buff.connect(process_stat_changes)
		elif status_effect.effect_type == "negative":
			status_effects_component.on_turn_update_debuff.connect(process_stat_changes)
	elif status_effect.duration_type == "SECONDS":
		if status_effect.effect_type == "positive":
			status_effects_component.on_second_update_buff.connect(process_stat_changes)
		elif status_effect.effect_type == "negative":
			status_effects_component.on_second_update_debuff.connect(process_stat_changes)

func on_start(effect: StatusEffect):
	if effect.name == status_effect_name:
		on_start_effect(effect)
		#on_start_effect2.emit(effect)
	
func on_end(effect: StatusEffect):
	if effect.name == status_effect_name:
		on_end_effect(effect)
		#on_end_effect2.emit(effect)

func process_stat_changes(effect: StatusEffect):
	if effect.name == status_effect_name:
		on_process_effect(effect)

#region overridable functions for classes that will derive from this class
# Can manipulate stat values here that are expected to only change once here
func on_start_effect(effect: StatusEffect):
	pass

func on_end_effect(effect: StatusEffect):
	pass

# handle whatever stat changes happens depending on its duration type is
# if duration_type == TURN, this code will process once per turn
# if duration_type == SECONDS, this code will process once per second
func on_process_effect(effect: StatusEffect):
	pass
	
#endregion
