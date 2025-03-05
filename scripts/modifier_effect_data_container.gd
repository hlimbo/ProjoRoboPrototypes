extends RefCounted
class_name ModifierEffectDataContainer

# key - modifier name (String)
# value - ModifierEffect
var buffs: Dictionary = {}
var debuffs: Dictionary = {}

func load_modifiers():
	var buff_reader = ModifierEffectCsvReader.new()
	var debuff_reader = ModifierEffectCsvReader.new()
	
	var buff_output: Array = buff_reader.read_csv_file("res://resources/csv/modifiers/buffs_csv.txt", "\t")
	var debuff_output: Array = debuff_reader.read_csv_file("res://resources/csv/modifiers/debuffs_csv.txt", "\t")
	
	store_modifiers(buff_output, buffs)
	store_modifiers(debuff_output, debuffs)

func store_modifiers(modifiers_src: Array, modifiers_target: Dictionary):
	for i in range(len(modifiers_src)):
		var modifier = modifiers_src[i] as ModifierEffect
		assert(modifier != null)
		modifiers_target[modifier.name] = modifier

func get_buff(name: String) -> ModifierEffect:
	if name not in buffs:
		return null
		
	return buffs[name]
	
func get_debuff(name: String) -> ModifierEffect:
	if name not in debuffs:
		return null
	
	return debuffs[name]
