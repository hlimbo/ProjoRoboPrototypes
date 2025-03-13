extends IPackedStringArrayConverter
class_name SkillsCsvReader

func on_convert(data: PackedStringArray) -> Skill:
	var skill = Skill.new()
	skill.name = data[0]
	skill.cost = float(data[1])
	skill.hp_modifier = Modifier.new("hp", "flat", float(data[2]))
	skill.energy_type = data[3]
	skill.description = data[4]
		
	return skill
