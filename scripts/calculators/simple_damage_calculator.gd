extends IDamageCalculator
class_name SimpleDamageCalculator

func calculate_damage(damage_receiver: Avatar, damage_dealer: Avatar) -> int:
	var dmg = maxi(damage_dealer.curr_stats.attack - damage_receiver.curr_stats.defense, 0)
	return dmg
