extends SkillBehavior
class_name CorkscrewSlashBehavior

func compute_stat_changes(target: LiteActor, raw_deltas: ModifierDelta) -> ModifierDelta:
	super.compute_stat_changes(target, raw_deltas)
	var net_deltas = ModifierDelta.new()
	
	var net_dmg: float = maxf(0.0, raw_deltas.hp.stat_value - target.stat_attributes.toughness.value)
	var net_hp = Modifier.create_hp(net_dmg)
	net_hp.is_positive = false
	net_deltas.hp = net_hp
	
	return net_deltas

# this is where you can deviate from the base implementation
# by writing your own calculations to modify stat changes APPLIED
# to the target
func apply_stat_changes(target: LiteActor, deltas: ModifierDelta):
	var dmg: float = deltas.hp.stat_value
	print("corkscrew slash deals %f damage!" % dmg)
	var new_hp: float = target.stat_attributes.hp.value + deltas.hp.get_value()
	target.stat_attributes.set_hp(new_hp)
