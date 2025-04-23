extends StatusEffectBehavior
class_name ThornyDefenseEffect2

#func _init():
	#self.on_start_effect2.connect(on_start_effect222)
	#self.on_end_effect2.connect(on_end_effect222)

# example of applying an effect
func on_start_effect(effect: StatusEffect):
	print("2. starting: ", effect.name)
	
	var tough_mod: Modifier = effect.get_modifier("toughness-mod")
	var speed_mod: Modifier = effect.get_modifier("slow-mod")
	
	var new_toughness: float = self.target.stat_attributes.toughness.value + tough_mod.get_value()
	var new_speed: float = self.target.stat_attributes.speed.value + speed_mod.get_value()
	
	self.target.stat_attributes.toughness.set_value(new_toughness)
	self.target.stat_attributes.speed.set_value(new_speed)
	self.target.stat_attributes.notify_all()

# example of undoing an effect
func on_end_effect(effect: StatusEffect):
	print("2. ending: ", effect.name)
	
	var tough_mod: Modifier = effect.get_modifier("toughness-mod")
	var speed_mod: Modifier = effect.get_modifier("slow-mod")
	
	var new_toughness: float = self.target.stat_attributes.toughness.value - tough_mod.get_value()
	var new_speed: float = self.target.stat_attributes.speed.value - speed_mod.get_value()
	
	self.target.stat_attributes.toughness.set_value(new_toughness)
	self.target.stat_attributes.speed.set_value(new_speed)
	self.target.stat_attributes.notify_all()
	
	## disconnect to cleanup
	#self.on_end_effect2.disconnect(on_end_effect222)
