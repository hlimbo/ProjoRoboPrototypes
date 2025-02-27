extends Node
class_name BotDataContainer

# key - bot name string
# value - AvatarData
var bot_table: Dictionary = {}

func load_bot_data():
	var reader = BotCsvReader.new()
	var bot_datum: Array = reader.read_csv_file("res://resources/csv/prototype_bots.txt", "\t")
	for data in bot_datum:
		var bot_data: AvatarData = (data as AvatarData)
		bot_table[bot_data.avatar_name] = bot_data
		print(bot_data.avatar_name)
		print(bot_data.energy_type)
		print(bot_data.bot_type)
		print("")

func get_bot(bot_name: String) -> AvatarData:
	if bot_name not in bot_table:
		return null
	
	return bot_table[bot_name]

# TODO: resolve issue with adding duplicate bots (maybe use uuid to look em up?)
func add_bot(data: AvatarData):
	assert(data.avatar_name not in bot_table)
	bot_table[data.avatar_name] = data
	
func remove_bot(bot_name: String) -> bool:
	assert(bot_name in bot_table)
	return bot_table.erase(bot_name)
	
func swap(bot_name1: String, bot_name2: String):
	assert(bot_name1 in bot_table)
	assert(bot_name2 in bot_table)
	
	var temp_ordinal: int = bot_table[bot_name1].ordinal
	bot_table[bot_name1].ordinal = bot_table[bot_name2].ordinal
	bot_table[bot_name2].ordinal = temp_ordinal
