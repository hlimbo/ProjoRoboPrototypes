extends StatusEffectBehavior
class_name ThornyDefenseEffect

func on_start_effect(effect: StatusEffect):
	print("starting: ", effect.name)
	
func on_end_effect(effect: StatusEffect):
	print("ending: ", effect.name)

func on_process_effect(effect: StatusEffect):
	pass
