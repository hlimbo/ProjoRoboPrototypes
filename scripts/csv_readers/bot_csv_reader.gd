extends IPackedStringArrayConverter
class_name BotCsvReader

# replace Variant with the specific object type being returned
func on_convert(data: PackedStringArray) -> AvatarData:
	var avatar_data = AvatarData.new()
	
	avatar_data.avatar_name = data[0]
	avatar_data.bot_type = data[1]
	avatar_data.energy_type = data[2]
	
	avatar_data.initial_stats = BaseStats.new()
	avatar_data.current_stats = BaseStats.new()
	
	avatar_data.initial_stats.hp = float(data[3])
	avatar_data.initial_stats.attack = float(data[4])
	avatar_data.initial_stats.defense = float(data[5])
	avatar_data.initial_stats.speed = float(data[6])
	avatar_data.current_stats.set_stats(avatar_data.initial_stats)

	return avatar_data
