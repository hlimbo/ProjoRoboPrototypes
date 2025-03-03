extends Node

enum ContainerType {
	DIGITAL_BANK,
	PARTY_BANK,
}

@export var utility: Utility = Utility

var digital_bot_bank: BotDataContainer
var party_bot_bank: BotDataContainer

# gets triggered in the following scenarios
# - when a bot is added into this container
# - when a bot is removed from this container
# - when 2 bots are swapped from the same container
signal on_digital_bank_view_update(data_container: BotDataContainer)
signal on_party_view_update(data_container: BotDataContainer)

func _init():
	digital_bot_bank = BotDataContainer.new()
	party_bot_bank = BotDataContainer.new()
	
	# TEMP: load in placeholder bot icons and pick random ones for each bot
	var resources: Array = utility.load_resources_from_folder("res://assets/kenney_emotes-pack/PNG/Vector/Style 2")
	
	# load in data into digital_bot_bank
	var reader = BotCsvReader.new()
	var bots: Array = reader.read_csv_file("res://resources/csv/prototype_bots.txt", "\t")
	
	var random_icon_resources: Array = utility.pick_unique_random_elements(resources, len(bots))
	var icons: Array[Texture2D] = []
	for res in random_icon_resources:
		icons.append(res as Texture2D)
		
	# load in placeholder bot preview art
	var bot_resources: Array = utility.load_resources_from_folder("res://nodes/prototype_bots")
	
	var bot_res_map: Dictionary = {}
	for bot_res in bot_resources:
		var bot_name: String = bot_res.resource_path.get_file().to_lower().trim_suffix(".tscn")
		bot_res_map[bot_name] = bot_res as PackedScene
	
	var index: int = 0
	for bot in bots:
		var avatar_data: AvatarData = bot as AvatarData
		avatar_data.level = 1
		avatar_data.ordinal = index
		avatar_data.avatar_icon = icons[index]
		avatar_data.avatar_preview = bot_res_map[avatar_data.avatar_name.to_lower()]
		
		digital_bot_bank.add_bot(avatar_data)
		index += 1
	
	# TEMP - add in bots to party
	for i in range(2):
		var avatar_data: AvatarData = bots[i] as AvatarData
		avatar_data.level = 1
		avatar_data.max_experience_per_level = 200
		avatar_data.current_experience = 0
		avatar_data.ordinal = i
		avatar_data.avatar_icon = icons[i]
		avatar_data.avatar_preview = bot_res_map[avatar_data.avatar_name.to_lower()]
		avatar_data.avatar_type = Constants.Avatar_Type.PARTY_MEMBER
		
		party_bot_bank.add_bot(avatar_data)
	
	# forward the signal upwards so external scripts can connect to this class's signals
	digital_bot_bank.on_update_view.connect(func(data_container: BotDataContainer): on_digital_bank_view_update.emit(data_container))
	party_bot_bank.on_update_view.connect(func(data_container: BotDataContainer): on_party_view_update.emit(data_container))

func swap_bots_in_digital_bank(bot_name1: String, bot_name2: String):
	_swap_internal(digital_bot_bank, bot_name1, bot_name2)

func swap_bots_in_party(bot_name1: String, bot_name2: String):
	_swap_internal(party_bot_bank, bot_name1, bot_name2)
	
func _swap_internal(container_src: BotDataContainer, bot_name1: String, bot_name2: String):
	container_src.swap(bot_name1, bot_name2)
	container_src.on_update_view.emit(container_src)
		
func _move_bot_internal(container_src: BotDataContainer, container_dst: BotDataContainer, bot_name: String, target_index: int):
	var bot: AvatarData = container_src.get_bot(bot_name)
	bot.ordinal = target_index
	container_src.remove_bot(bot_name)
	container_dst.add_bot(bot)
	
	container_src.on_update_view.emit(container_src)
	container_dst.on_update_view.emit(container_dst)

# target_index is the new position the bot will be placed in the layout
func move_to_digital_bank(bot_name: String, target_index: int):
	_move_bot_internal(party_bot_bank, digital_bot_bank, bot_name, target_index)

# target_index is the new position the bot will be placed in the layout
func move_to_party(bot_name: String, target_index: int):
	_move_bot_internal(digital_bot_bank, party_bot_bank, bot_name, target_index)

func swap_bots_from_digital_bank_to_party(bot_name_from_bank: String, bot_name_from_party: String):
	_swap_across_banks_internal(digital_bot_bank, party_bot_bank, bot_name_from_bank, bot_name_from_party)

func swap_bots_from_party_to_digital_bank(bot_name_from_party: String, bot_name_from_bank: String):
	_swap_across_banks_internal(party_bot_bank, digital_bot_bank, bot_name_from_party, bot_name_from_bank)

func _swap_across_banks_internal(container_src: BotDataContainer, container_dst: BotDataContainer, src_bot_name: String, dst_bot_name: String):
	var bot1: AvatarData = container_src.get_bot(src_bot_name)
	var bot2: AvatarData = container_dst.get_bot(dst_bot_name)
	
	container_src.remove_bot(src_bot_name)
	container_dst.remove_bot(dst_bot_name)
	
	var temp_index: int = bot1.ordinal
	bot1.ordinal = bot2.ordinal
	bot2.ordinal = temp_index
	
	container_src.add_bot(bot2)
	container_dst.add_bot(bot1)
	
	container_src.on_update_view.emit(container_src)
	container_dst.on_update_view.emit(container_dst)

func move_bot_in_digital_bank(bot_name: String, target_index: int):
	_move_bot_internal2(digital_bot_bank, bot_name, target_index)
	
func move_bot_in_party(bot_name: String, target_index: int):
	_move_bot_internal2(party_bot_bank, bot_name, target_index)
	
func _move_bot_internal2(data_src: BotDataContainer, bot_name: String, target_index: int):
	var bot: AvatarData = data_src.get_bot(bot_name)
	bot.ordinal = target_index
	data_src.on_update_view.emit(data_src)
	
func get_bot(bot_name: String):
	if bot_name in digital_bot_bank.bot_table:
		return digital_bot_bank.get_bot(bot_name)
	
	return party_bot_bank.get_bot(bot_name)
	
func get_party_members() -> Array[AvatarData]:
	var arr: Array = party_bot_bank.bot_table.values()
	var output: Array[AvatarData] = []
	for item in arr:
		output.append(item as AvatarData)
	return output
