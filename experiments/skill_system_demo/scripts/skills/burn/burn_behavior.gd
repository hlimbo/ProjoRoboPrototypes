extends SkillBehavior
class_name BurnBehavior

func apply_stat_changes(target: LiteActor, deltas: ModifierDelta):
	var dmg: float = deltas.hp.stat_value
	# displaying damage can be sent over an event bus so that the UI can display this number
	print("burn does %f damage initially" % dmg) 
	var new_hp: float = target.stat_attributes.hp.value + deltas.hp.get_value()
	target.stat_attributes.set_hp(new_hp)
