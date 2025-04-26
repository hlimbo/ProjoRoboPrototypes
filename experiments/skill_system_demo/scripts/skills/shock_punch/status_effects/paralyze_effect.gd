extends StatusEffectBehavior
class_name ParalyzeEffect

func on_process_effect(effect: StatusEffect):
	# stop target actor from making any action this turn/this second
	# Examples include disabling buttons target actor can press this turn
	# Other example includes skipping their turn --> which would need to update a
	# flag in the actor class to skip turn
	pass
