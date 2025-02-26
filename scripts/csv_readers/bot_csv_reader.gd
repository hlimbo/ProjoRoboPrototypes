extends IPackedStringArrayConverter
class_name BotCsvReader

# replace Variant with the specific object type being returned
func on_convert(data: PackedStringArray) -> AvatarData:
	var avatar_data = AvatarData.new()
	
	avatar_data.avatar_name = data[0]
	avatar_data.bot_type = data[1]
	avatar_data.energy_type = data[2]

	return avatar_data
