extends IPackedStringArrayConverter
class_name ModifierEffectCsvReader

# TODO: remake csv dataset
func on_convert(data: PackedStringArray) -> Modifier:
	# there should be 9 columns being read from the CSV file
	assert(len(data) == 9)
	
	var modifier_effect = Modifier.new()
	
	modifier_effect.name = data[0]
	modifier_effect.description = data[1]
	modifier_effect.duration_type = data[2]
	modifier_effect.duration = float(data[3])
	
	modifier_effect.damage_type = data[4]
	modifier_effect.damage = float(data[5])
	modifier_effect.stat_modifier_category = data[6]
	modifier_effect.stat_modifier_type = data[7]
	modifier_effect.stat_value = float(data[8])

	return modifier_effect
