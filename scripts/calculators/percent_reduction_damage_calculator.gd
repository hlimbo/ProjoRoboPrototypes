extends IDamageCalculator
class_name PercentReductionDamageCalculator

func calculate_damage(damage_receiver: Avatar, damage_dealer: Avatar) -> int:
	# TODO - get max defense stat this game can ever have to compute defense percentage
	var defense_percent = 50
	var dmg = damage_dealer.curr_stats.attack * ((100 - defense_percent) / 100)
	return dmg
