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

func _ready():
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

	var index: int = 0
	for bot in bots:
		var avatar_data: AvatarData = (bot as AvatarData)
		avatar_data.level = 1
		avatar_data.ordinal = index
		avatar_data.avatar_icon = icons[index]
		
		digital_bot_bank.add_bot(avatar_data)
		index += 1
		
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
