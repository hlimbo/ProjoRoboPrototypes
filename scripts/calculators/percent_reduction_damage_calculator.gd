extends IDamageCalculator
class_name PercentReductionDamageCalculator

func calculate_damage(damage_receiver: Actor, damage_dealer: Actor) -> int:
	# TODO - get max defense stat this game can ever have to compute defense percentage
	var dd_attack = damage_dealer.avatar.avatar_data.current_stats.attack
	var defense_percent = 50
	var dmg = damage_dealer.avatar.avatar_data.current_stats.attack * ((100 - defense_percent) / 100)
	return dmg
