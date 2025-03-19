extends RefCounted
class_name StatusEffectDataContainer

# key - status effect name (String)
# value - StatusEffect
var buffs: Dictionary = {}
var debuffs: Dictionary = {}

func load_modifiers(file_path: String):
	var reader = StatusEffectCsvReader.new()
	
	var output: Array = reader.read_csv_file(file_path, "\t")
	assert(len(output) > 0)
	
	for i in range(len(output)):
		var status_effect = output[i] as StatusEffect
		assert(is_instance_valid(status_effect))
		if status_effect.effect_type == "positive":
			buffs[status_effect.name] = status_effect
		else:
			debuffs[status_effect.name] = status_effect


func get_buff(name: String) -> StatusEffect:
	if name not in buffs:
		return null
		
	return buffs[name]
	
func get_debuff(name: String) -> StatusEffect:
	if name not in debuffs:
		return null
	
	return debuffs[name]
	
