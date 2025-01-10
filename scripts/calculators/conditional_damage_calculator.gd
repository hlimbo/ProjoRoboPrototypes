extends IDamageCalculator
class_name ConditionalDamageCalculator

func calculate_damage(damage_receiver: Avatar, damage_dealer: Avatar) -> int:
	var dmg = 0
	var attack = damage_dealer.curr_stats.attack
	var defense = damage_receiver.curr_stats.defense
	
	if attack >= defense:
		dmg = attack - (defense / 2)
	else:
		dmg = attack * (attack / 2 * defense)
	
	return dmg
