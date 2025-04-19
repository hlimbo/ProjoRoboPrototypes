extends Node

func calculate_raw_stat_value(stats: StatAttributeSet, modifiers: Array[Modifier]) -> Array[Modifier]:
	# 1. define raw modifier types
	var hp_modifier = Modifier.new(Constants.STAT_NONE, Constants.STAT_HP)
	var energy_modifier = Modifier.new(Constants.STAT_NONE, Constants.STAT_ENERGY)
	var str_modifier = Modifier.new(Constants.STAT_NONE, Constants.STAT_STRENGTH)
	var toughness_modifier = Modifier.new(Constants.STAT_NONE, Constants.STAT_TOUGHNESS)
	var speed_modifier = Modifier.new(Constants.STAT_NONE, Constants.STAT_SPEED)
	
	# 2a. for each modifier convert to flat value
	# 2b. add each modifier to raw modifier grouped by raw modifier
	for modifier in modifiers:
		var flat_modifier: Modifier = Utility.convert_percent_to_flat_modifier(stats, modifier)
		match flat_modifier.stat_category_type_target:
			Constants.STAT_HP:
				hp_modifier.stat_value += flat_modifier.stat_value
			Constants.STAT_ENERGY:
				energy_modifier.stat_value += flat_modifier.stat_value
			Constants.STAT_STRENGTH:
				str_modifier.stat_value += flat_modifier.stat_value
			Constants.STAT_TOUGHNESS:
				toughness_modifier.stat_value += flat_modifier.stat_value
			Constants.STAT_SPEED:
				speed_modifier.stat_value += flat_modifier.stat_value
		
	return [
		hp_modifier,
		energy_modifier,
		str_modifier,
		toughness_modifier,
		speed_modifier,
	]


func calculate_net_damage_simple(caster_stats: StatAttributeSet, target_stats: StatAttributeSet, raw_dmg: Modifier) -> Modifier:
	assert(raw_dmg.modifier_type == Constants.MODIFIER_FLAT)
	assert(raw_dmg.stat_category_type_target == Constants.STAT_HP)
	
	var net_damage = Modifier.new(Constants.STAT_NONE, Constants.STAT_HP)
	net_damage.stat_value = raw_dmg.stat_value -  target_stats.toughness.value
	
	return net_damage
