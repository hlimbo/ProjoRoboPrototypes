extends Control
class_name StatusEffectLoader

@export var status_effect_row: Resource
# key = status effect name string | value StatusEffectRow
@export var status_effects: Dictionary = {}

func _on_add_status_effect(effect: StatusEffect):
	var row = status_effect_row.instantiate() as StatusEffectRow
	self.add_child(row)
	# move to front of list
	self.move_child(row, 0)
	row.update_fields(effect)
	status_effects[effect.name] = row

func _on_remove_status_effect(effect: StatusEffect):
	assert(effect != null && effect.name in status_effects)
	var row: StatusEffectRow = status_effects[effect.name]
	status_effects.erase(effect.name)
	self.remove_child(row)
	row.queue_free()

func on_add_buff(effect: StatusEffect):
	_on_add_status_effect(effect)
	
func on_add_debuff(effect: StatusEffect):
	_on_add_status_effect(effect)
	
func on_remove_buff(effect: StatusEffect):
	_on_remove_status_effect(effect)

func on_remove_debuff(effect: StatusEffect):
	_on_remove_status_effect(effect)
