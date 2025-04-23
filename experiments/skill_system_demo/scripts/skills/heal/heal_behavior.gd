extends SkillBehavior
class_name HealBehavior

func apply_stat_changes(caster: LiteActor, target: LiteActor, deltas: ModifierDelta):
	super.apply_stat_changes(caster, target, deltas)

	var new_hp: float = target.stat_attributes.hp.value + deltas.hp.stat_value
	target.stat_attributes.set_hp(new_hp)
