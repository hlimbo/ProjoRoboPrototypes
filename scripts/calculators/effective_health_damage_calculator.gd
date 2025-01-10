extends IDamageCalculator
class_name EffectiveHealthDamageCalculator

func calculate_damage(damage_receiver: Avatar, damage_dealer: Avatar) -> int:
	var dmg =damage_dealer.curr_stats.attack * (100 / (damage_receiver.curr_stats.defense + 100))
	return dmg
