extends IPackedStringArrayConverter
class_name SkillsCsvReader

func on_convert(data: PackedStringArray) -> Skill:
	var skill = Skill.new()
	skill.name = data[0]
	skill.cost = float(data[1])
	skill.attack = float(data[2])
	skill.energy_type = data[3]
	skill.description = data[4]
	var target_buffs: PackedStringArray = data[5].split(";")
	var target_debuffs: PackedStringArray = data[6].split(";")
	
	for buff in target_buffs:
		skill.target_buffs.append(buff)
	for debuff in target_debuffs:
		skill.target_debuffs.append(debuff)
	
	
	return skill
