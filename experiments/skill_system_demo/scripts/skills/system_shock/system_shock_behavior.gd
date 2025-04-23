extends SkillBehavior
class_name SystemShockBehavior

func apply_stat_changes(target: LiteActor, deltas: ModifierDelta):
	var dmg: float = deltas.hp.stat_value
	print("damage: ", dmg)
	var new_hp: float = target.stat_attributes.hp.value + deltas.hp.get_value()
	target.stat_attributes.set_hp(new_hp)
