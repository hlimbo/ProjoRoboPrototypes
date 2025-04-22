extends StatusEffectBehavior
class_name BurnEffect

func on_process_effect(effect: StatusEffect):
	var dmg_mod: Modifier = effect.get_modifier("burn-mod")
	print("burn effect applied dealing %f dmg" % dmg_mod.stat_value)
	var new_hp = target.stat_attributes.hp.value + dmg_mod.get_value()
	target.stat_attributes.set_hp(new_hp)
