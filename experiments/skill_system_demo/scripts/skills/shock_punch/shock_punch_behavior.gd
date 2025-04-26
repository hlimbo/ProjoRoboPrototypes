extends SkillBehavior
class_name ShockPunchBehavior

func apply_stat_changes(caster: LiteActor, target: LiteActor, deltas: ModifierDelta):
	super.apply_stat_changes(caster, target, deltas)
	var net_dmg: float = deltas.hp.get_value()
	print("Shock Punch deals %f damage", net_dmg)
	var new_hp: float = target.stat_attributes.hp.value + net_dmg
	target.stat_attributes.set_hp(new_hp)
