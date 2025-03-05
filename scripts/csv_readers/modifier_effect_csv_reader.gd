extends IPackedStringArrayConverter
class_name ModifierEffectCsvReader

func on_convert(data: PackedStringArray) -> ModifierEffect:
	var modifier_effect = ModifierEffect.new()
	
	modifier_effect.name = data[0]
	modifier_effect.description = data[1]
	modifier_effect.duration_type = data[2]
	modifier_effect.duration = data[3]

	return modifier_effect
