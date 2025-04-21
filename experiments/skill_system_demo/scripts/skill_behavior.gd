extends Node
class_name SkillBehavior

var buff_behaviors: Array[StatusEffectBehavior] = []
var debuff_behaviors: Array[StatusEffectBehavior] = []

#region NON-overridable functions
func apply_cost(caster: LiteActor, skill: Skill):
	var energy: float = caster.stat_attributes.energy.value - skill.cost
	caster.stat_attributes.set_energy(energy)

func add_status_effects(target: LiteActor, skill: Skill, buffs: Array[StatusEffectBehavior] = [], debuffs: Array[StatusEffectBehavior] = []):
	assert(len(skill.buffs) == len(buffs))
	assert(len(skill.debuffs) == len(debuffs))
	
	for i in range(len(skill.buffs)):
		var effect: StatusEffect = skill.buffs[i]
		var behavior: StatusEffectBehavior = buffs[i]
		behavior.initialize(effect, target.status_effects)
		target.status_effects.add_buff(effect)
	
	for i in range(len(skill.debuffs)):
		var effect: StatusEffect = skill.debuffs[i]
		var behavior: StatusEffectBehavior = debuffs[i]
		behavior.initialize(effect, target.status_effects)
		target.status_effects.add_debuff(effect)
#endregion

# process changes to stats gets executed as soon as the skill triggers on a given frame in the game loop
func accumulate_raw_stat_changes(caster: LiteActor, target: LiteActor, skill: Skill) -> ModifierDelta:
	# Calculate raw stat value changes (accumulators)
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

	return ModifierDelta.new(hp_modifier, energy_modifier, strength_modifier, toughness_modifier, speed_modifier)

func compute_stat_changes(target: LiteActor, raw_deltas: ModifierDelta) -> ModifierDelta:
	assert(raw_deltas.hp.modifier_type == Constants.MODIFIER_FLAT)
	assert(raw_deltas.energy.modifier_type == Constants.MODIFIER_FLAT)
	assert(raw_deltas.strength.modifier_type == Constants.MODIFIER_FLAT)
	assert(raw_deltas.toughness.modifier_type == Constants.MODIFIER_FLAT)
	assert(raw_deltas.speed.modifier_type == Constants.MODIFIER_FLAT)
	return ModifierDelta.new()

# this is where you can deviate from the base implementation
# by writing your own calculations to modify stat changes APPLIED
# to the target
func apply_stat_changes(target: LiteActor, deltas: ModifierDelta):
	pass
