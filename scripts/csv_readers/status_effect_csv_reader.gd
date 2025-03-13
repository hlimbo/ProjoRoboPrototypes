extends IPackedStringArrayConverter
class_name StatusEffectCsvReader

func on_convert(data: PackedStringArray) -> StatusEffect:
	# there should be 8 columns being read from the CSV file
	assert(len(data) == 8)
	
	var status_effect = StatusEffect.new()
	var modifier = Modifier.new()
	
	status_effect.name = data[0]
	status_effect.description = data[1]
	status_effect.duration_type = data[2]
	status_effect.duration = float(data[3])
	
	modifier.stat_category_type = data[4]
	modifier.stat_value_type = data[5]
	modifier.stat_value = float(data[6])
	status_effect.modifiers.append(modifier)
	
	status_effect.effect_type = data[7]

	return status_effect
