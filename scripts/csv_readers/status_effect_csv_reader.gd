extends IPackedStringArrayConverter
class_name StatusEffectCsvReader

func on_convert(data: PackedStringArray) -> StatusEffect:
	# there should be 10 columns being read from the CSV file
	assert(len(data) == 10)
	
	var status_effect = StatusEffect.new()
	var modifier = Modifier.new()
	
	status_effect.name = data[0]
	status_effect.description = data[1]
	status_effect.duration_type = data[2]
	status_effect.duration = float(data[3])
	
	modifier.name = "%s-modifier" % status_effect.name
	modifier.stat_category_type_src = data[4]
	modifier.stat_category_type_target = data[5]
	modifier.modifier_type = data[6]
	modifier.stat_value = float(data[7])
	status_effect.modifiers[status_effect.name] = modifier
	
	status_effect.effect_type = data[8]
	status_effect.target = data[9]

	return status_effect
