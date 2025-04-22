extends Node
class_name StatusEffectBehavior
# purpose -> to process any kind of status effect
# so that more can be pumped out quickly in an organized fashion

# what we need
# status effect
# target affected by the status
#   -> stats

# logic
# if effect matches the name we look for process it
# otherwise ignore it....
# can I do better?
# can polymorphism be used here to handle process any kind of effects?

# zoom in
# status effect
# status_effects_component - to connect whichever
# signal that this status effect will handle

# used to identify which status_effect to handle
var status_effect_name: String

func initialize(status_effect: StatusEffect, status_effects_component: StatusEffectsComponent):
	status_effect_name = status_effect.name
	
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
	
func on_end(effect: StatusEffect):
	if effect.name == status_effect_name:
		on_end_effect(effect)

func process_stat_changes(effect: StatusEffect):
	if effect.name == status_effect_name:
		on_process_effect(effect)

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
