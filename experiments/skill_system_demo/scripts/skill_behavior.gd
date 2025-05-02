extends RefCounted
class_name SkillBehavior

var skill: Skill
var buff_behaviors: Array[StatusEffectBehavior] = []
var debuff_behaviors: Array[StatusEffectBehavior] = []

# Skill Lifecycle
# on skill begin
# on skill apply
# on skill end

func _init(new_skill: Skill, buffs: Array[StatusEffectBehavior] = [], debuffs: Array[StatusEffectBehavior] = []):
	assert(len(new_skill.buffs) == len(buffs))
	assert(len(new_skill.debuffs) == len(debuffs))
	
	skill = new_skill
	buff_behaviors.append_array(buffs)
	debuff_behaviors.append_array(debuffs)
	
	for i in range(len(skill.buffs)):
		buffs[i].init_effect(skill.buffs[i])
	
	for i in range(len(skill.debuffs)):
		debuffs[i].init_effect(skill.debuffs[i])

# uncomment to verify this instance is being deleted
#func _notification(what: int):
	## equivalent to a deconstructor in C++
	## gets called when all references to this object reaches 0
	#if what == NOTIFICATION_PREDELETE:
		#print("deleting this SkillBehavior: %s" % skill.name)

# binding the functions to the data
func bind_status_effects(caster: LiteActor, target: LiteActor):
	assert(len(skill.buffs) == len(buff_behaviors))
	assert(len(skill.debuffs) == len(debuff_behaviors))
	
	for i in range(len(skill.buffs)):
		var effect: StatusEffect = skill.buffs[i]
		var behavior: StatusEffectBehavior = buff_behaviors[i]
		behavior.initialize(caster, target)
		
	for i in range(len(skill.debuffs)):
		var effect: StatusEffect = skill.debuffs[i]
		var behavior: StatusEffectBehavior = debuff_behaviors[i]
		behavior.initialize(caster, target)
	
	# remove buff_behaviors and debuff_behaviors as its lifetime will be managed
	# by status_effect_behavior_manager.gd
	buff_behaviors.clear()
	debuff_behaviors.clear()

func start_status_effects(target: LiteActor):
	for buff in skill.buffs:
		target.status_effects.add_buff(buff)
	
	for debuff in skill.debuffs:
		target.status_effects.add_debuff(debuff)
	
func end_status_effects(target: LiteActor):
	for buff in skill.buffs:
		target.status_effects.remove_buff(buff)
	
	for debuff in skill.debuffs:
		target.status_effects.remove_debuff(debuff)

# process changes to stats gets executed as soon as the skill triggers on a given frame in the game loop
func accumulate_raw_stat_changes(caster: LiteActor, target: LiteActor) -> ModifierDelta:
	# Calculate raw stat value changes (accumulators)
	var hp_modifier = Modifier.create_hp()
	var energy_modifier = Modifier.create_energy()
	var strength_modifier = Modifier.create_strength()
	var toughness_modifier = Modifier.create_toughness()
	var speed_modifier = Modifier.create_speed()
	
	for modifier in skill.get_modifiers():
		var flat_modifier: Modifier = Utility.convert_percent_to_flat_modifier(caster.stat_attributes, modifier)
		
		match flat_modifier.stat_category_type_target:
			Constants.STAT_HP:
				hp_modifier.stat_value += flat_modifier.get_value()
			Constants.STAT_ENERGY:
				energy_modifier.stat_value += flat_modifier.get_value()
			Constants.STAT_STRENGTH:
				strength_modifier.stat_value += flat_modifier.get_value()
			Constants.STAT_TOUGHNESS:
				toughness_modifier.stat_value += flat_modifier.get_value()
			Constants.STAT_SPEED:
				speed_modifier.stat_value += flat_modifier.get_value()
	
	# check signs of each attribute to ensure the correct addition/subtraction operation can be made later down the line
	hp_modifier = Utility.convert_to_absolute_value(hp_modifier)
	energy_modifier = Utility.convert_to_absolute_value(energy_modifier)
	strength_modifier = Utility.convert_to_absolute_value(strength_modifier)
	toughness_modifier = Utility.convert_to_absolute_value(toughness_modifier)
	speed_modifier = Utility.convert_to_absolute_value(speed_modifier)

	return ModifierDelta.new(hp_modifier, energy_modifier, strength_modifier, toughness_modifier, speed_modifier)

func compute_stat_changes(target: LiteActor, raw_deltas: ModifierDelta) -> ModifierDelta:
	assert(raw_deltas.hp.modifier_type == Constants.MODIFIER_FLAT)
	assert(raw_deltas.energy.modifier_type == Constants.MODIFIER_FLAT)
	assert(raw_deltas.strength.modifier_type == Constants.MODIFIER_FLAT)
	assert(raw_deltas.toughness.modifier_type == Constants.MODIFIER_FLAT)
	assert(raw_deltas.speed.modifier_type == Constants.MODIFIER_FLAT)
	return raw_deltas

# this is where you can deviate from the base implementation
# by writing your own calculations to modify stat changes APPLIED
# to the target
func apply_stat_changes(caster: LiteActor, target: LiteActor, deltas: ModifierDelta):
	# apply energy reduction here - all skills should cost energy to cast
	var new_energy: float = caster.stat_attributes.energy.value + deltas.energy.get_value()
	caster.stat_attributes.set_energy(new_energy)
