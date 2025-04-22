extends StatusEffectBehavior
class_name HealRegenEffect

func on_process_effect(effect: StatusEffect):
	var heal_mod: Modifier = effect.get_modifier("heal-mod")
	var flat: Modifier = Utility.convert_percent_to_flat_modifier(target.stat_attributes, heal_mod)
	
	print("gaining %f hp now" % flat.get_value())
	
	var new_hp: float = self.target.stat_attributes.hp.value + flat.get_value()
	self.target.stat_attributes.set_hp(new_hp)
