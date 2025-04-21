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

var status_effect: StatusEffect
var status_effects_component: StatusEffectsComponent

func initialize(_status_effect: StatusEffect, _status_effects_component: StatusEffectsComponent):
	status_effect = _status_effect
	status_effects_component = _status_effects_component
	
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
	elif status_effect.duration_type == "ONE-SHOT":
		process_stat_changes()

# handle whatever stat changes happens depending on its duration type is
# if duration_type == TURN, this code will process once per turn
# if duration_type == SECONDS, this code will process once per second
# if duration_type == ONE-SHOT, this code will process on the frame it is called on ONCE
func process_stat_changes():
	pass
