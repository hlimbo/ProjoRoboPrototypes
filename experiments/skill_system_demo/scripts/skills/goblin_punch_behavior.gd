extends SkillBehavior
class_name GoblinPunchBehavior

func compute_stat_changes(target: LiteActor, raw_deltas: ModifierDelta) -> ModifierDelta:
	super.compute_stat_changes(target, raw_deltas)
	# Example of how to do damage calculations
	var raw_dmg: float = raw_deltas.hp.stat_value
	var net_dmg: float = maxf(raw_dmg- target.stat_attributes.toughness.value, 0.0)
	return ModifierDelta.new(Modifier.create_hp(net_dmg))

func apply_stat_changes(target: LiteActor, deltas: ModifierDelta):
	# final damage calculations
	var dmg: float = deltas.hp.stat_value
	var new_hp: float = maxf(target.stat_attributes.hp.value - dmg, 0.0)
	target.stat_attributes.set_hp(new_hp)
