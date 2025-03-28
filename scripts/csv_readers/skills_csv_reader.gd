extends IPackedStringArrayConverter
class_name SkillsCsvReader

func on_convert(data: PackedStringArray) -> Skill:
	var skill = Skill.new()
	skill.name = data[0]
	skill.cost = float(data[1])
	var damage_modifier = Modifier.new("no_stat", "hp", "flat", float(data[2]))
	skill.modifiers.append(damage_modifier)
	skill.energy_type = data[3]
	skill.description = data[4]
	
	var buff_labels: PackedStringArray = data[5].split(';')
	var debuff_labels: PackedStringArray = data[6].split(';')
	
	var buff_effects: Array[StatusEffect] = []
	var debuff_effects: Array[StatusEffect] = []
	
	for buff in buff_labels:
		buff_effects.append(StatusEffect.new(buff))
	for debuff in debuff_labels:
		debuff_effects.append(StatusEffect.new(debuff))
		
	skill.buffs = buff_effects
	skill.debuffs = debuff_effects
		
	return skill
