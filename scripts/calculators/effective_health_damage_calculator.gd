extends IDamageCalculator
class_name EffectiveHealthDamageCalculator

func calculate_damage(damage_receiver: Actor, damage_dealer: Actor) -> int:
	var dd_attack = damage_dealer.avatar.avatar_data.current_stats.attack
	var dr_def = damage_receiver.avatar.avatar_data.current_stats.defense
	var dmg = dd_attack * (100 / (dr_def + 100))
	return dmg
