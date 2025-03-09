extends IDamageCalculator
class_name ConditionalDamageCalculator

func calculate_damage(damage_receiver: Actor, damage_dealer: Actor) -> int:
	var dmg = 0
	var attack = damage_dealer.avatar.avatar_data.current_stats.attack
	var defense = damage_receiver.avatar_data.current_stats.defense
	
	if attack >= defense:
		dmg = attack - (defense / 2)
	else:
		dmg = attack * (attack / 2 * defense)
	
	return dmg
