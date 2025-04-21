extends Node
class_name SkillBehavior

# Try this out with Goblin Punch
func apply_cost(caster: LiteActor, skill: Skill):
	var energy: float = caster.stat_attributes.energy.value - skill.cost
	caster.stat_attributes.set_energy(energy)

func process_stat_changes(caster: LiteActor, target: LiteActor, skill: Skill) -> ModifierDelta:
	# 1. Calculate raw stat value changes (accumulators)
	var hp_modifier = Modifier.create_hp()
	var energy_modifier = Modifier.create_energy()
	var strength_modifier = Modifier.create_strength()
	var toughness_modifier = Modifier.create_toughness()
	var speed_modifier = Modifier.create_speed()
	
	for modifier in skill.modifiers:
		var flat_modifier: Modifier = Utility.convert_percent_to_flat_modifier(caster.stat_attributes, modifier)
		
		match flat_modifier.stat_category_type_target:
			Constants.STAT_HP:
				hp_modifier.stat_value += flat_modifier.stat_value
			Constants.STAT_ENERGY:
				energy_modifier.stat_value += flat_modifier.stat_value
			Constants.STAT_STRENGTH:
				strength_modifier.stat_value += flat_modifier.stat_value
			Constants.STAT_TOUGHNESS:
				toughness_modifier.stat_value += flat_modifier.stat_value
			Constants.STAT_SPEED:
				speed_modifier.stat_value += flat_modifier.stat_value
				
	# 2. Obtain net stat value by calculating raw stat values against p2 resistances
	# Could be more complicated than this and require an interface function to compute this value...
	var dmg: float = hp_modifier.stat_value - target.stat_attributes.toughness.value
	var net_hp = Modifier.create_hp(dmg)
	var net_energy = Modifier.create_energy()
	var net_strength = Modifier.create_strength()
	var net_toughness = Modifier.create_toughness()
	var net_speed = Modifier.create_speed()

	return ModifierDelta.new(net_hp)
	
	## 3. apply stat changes
	#target.stat_attributes.set_hp(net_hp)
	
func process_status_effects(caster: LiteActor, target: LiteActor, skill: Skill):
	for effect in skill.buffs:
		pass
