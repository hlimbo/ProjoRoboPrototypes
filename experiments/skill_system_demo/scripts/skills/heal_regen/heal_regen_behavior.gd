extends SkillBehavior
class_name HealRegenBehavior

func apply_stat_changes(caster: LiteActor, target: LiteActor, deltas: ModifierDelta):
	super.apply_stat_changes(caster, target, deltas)

	var heal_amt: float = deltas.hp.stat_value
	print("heal regen initial heal for: %f" % heal_amt)
	var new_hp: float = target.stat_attributes.hp.value + deltas.hp.get_value()
	target.stat_attributes.set_hp(new_hp)
