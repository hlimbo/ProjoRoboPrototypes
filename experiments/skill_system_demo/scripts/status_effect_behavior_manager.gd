# Purpose: keep StatusEffectBehavior alive
# until it finishes its effect
extends Node
# class_name StatusEffectBehaviorManager

var effects: Array[StatusEffectBehavior] = []
# key - effect name
# value = time since effect started. measured in milliseconds
var effect_start_times: Dictionary[String, float] = {}

func add_effect(effect: StatusEffectBehavior):
	#if effect.status_effect.name not in effect_start_times:
		#if effect.status_effect.duration_type == "TURN":
			#effect_start_times[effect.status_effect.name] = current_turn
		#elif effect.status_effect.duration_type == "SECONDS":
			#effect_start_times[effect.status_effect.name] = current_time
	effects.append(effect)

func start_effect(effect: StatusEffect, current_time: float, current_turn: int):
	# don't overwrite the times if already in dictionary
	var effect_name: String = effect.name
	if effect_name in effect_start_times:
		return
	
	if effect.duration_type == "TURN":
		effect_start_times[effect_name] = current_turn
	elif effect.duration_type == "SECONDS":
		effect_start_times[effect_name] = current_time

func check_effect_removal(current_time: float, current_turn: int):
	var behaviors_to_remove: Array[int] = []
	for i in range(len(effects)):
		var effect: StatusEffectBehavior = effects[i]
		if effect.status_effect.duration_type == "ONE-SHOT":
			continue
		
		var effect_name: String = effect.status_effect.name
		assert(effect_name in effect_start_times)
		
		if effect.status_effect.duration_type == "TURN":
			var turn_diff: float = current_turn - int(effect_start_times[effect_name])
			if turn_diff >= effect.status_effect.duration:
				behaviors_to_remove.append(i)
				effect_start_times.erase(effect_name)
		
		elif effect.status_effect.duration_type == "SECONDS":
			var millis_to_secs: float = 1000.0
			var time_diff: float = (current_time - effect_start_times[effect_name]) / millis_to_secs
			if time_diff >= effect.status_effect.duration:
				print("time diff: ", time_diff)
				behaviors_to_remove.append(i)
				effect_start_times.erase(effect_name)
				
	for behavior_index in behaviors_to_remove:
		effects.remove_at(behavior_index)
			
