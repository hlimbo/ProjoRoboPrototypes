extends SkillBehavior
class_name SystemShockBehavior

func apply_stat_changes(caster: LiteActor, target: LiteActor, deltas: ModifierDelta):
	super.apply_stat_changes(caster, target, deltas)
	var dmg: float = deltas.hp.stat_value
	print("damage: ", dmg)
	var new_hp: float = target.stat_attributes.hp.value + deltas.hp.get_value()
	target.stat_attributes.set_hp(new_hp)
