extends SkillBehavior
class_name HealBehavior

func apply_stat_changes(target: LiteActor, deltas: ModifierDelta):
	var new_hp: float = target.stat_attributes.hp.value + deltas.hp.stat_value
	target.stat_attributes.set_hp(new_hp)
