extends IPackedStringArrayConverter
class_name SkillsCsvReader

func on_convert(data: PackedStringArray) -> Skill:
	var skill = Skill.new()
	skill.name = data[0]
	skill.cost = float(data[1])
	skill.hp_modifier = Modifier.new("no_stat", "hp", "flat", float(data[2]))
	skill.energy_type = data[3]
	skill.description = data[4]
	skill.buffs = data[5].split(';')
	skill.debuffs = data[6].split(';')
		
	return skill
