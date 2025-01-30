extends IDamageCalculator
class_name SimpleDamageCalculator

func calculate_damage(damage_receiver: Actor, damage_dealer: Actor) -> int:
	var dd_attack = damage_dealer.avatar.curr_stats.attack
	var dr_def = damage_receiver.avatar.curr_stats.defense
	var dmg = maxi(dd_attack - dr_def, 0)
	return dmg
