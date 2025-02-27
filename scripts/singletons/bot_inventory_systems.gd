extends Node

enum ContainerType {
	DIGITAL_BANK,
	PARTY_BANK,
}

var digital_bot_bank: BotDataContainer
var party_bot_bank: BotDataContainer

signal on_digital_bank_view_update(data_container: BotDataContainer)
signal on_party_view_update(data_container: BotDataContainer)

func _ready():
	digital_bot_bank = BotDataContainer.new()
	party_bot_bank = BotDataContainer.new()
	
	# load in data into digital_bot_bank
	var reader = BotCsvReader.new()
	var bots: Array = reader.read_csv_file("res://resources/csv/prototype_bots.txt", "\t")
	var ordinal_index: int = 0

	for bot in bots:
		var avatar_data: AvatarData = (bot as AvatarData)
		avatar_data.level = 1
		avatar_data.ordinal = ordinal_index
		
		digital_bot_bank.add_bot(avatar_data)
		ordinal_index += 1
		
	# forward the signal upwards so external scripts can connect to this class's signals
	digital_bot_bank.on_update_view.connect(func(data_container: BotDataContainer): on_digital_bank_view_update.emit(data_container))
	party_bot_bank.on_update_view.connect(func(data_container: BotDataContainer): on_party_view_update.emit(data_container))

func swap_bots(bot_name1: String, bot_name2: String):
	var b1: AvatarData = digital_bot_bank.get_bot(bot_name1)
	var b2: AvatarData = party_bot_bank.get_bot(bot_name2)
	
	if b1 != null and b2 != null:
		_swap_internal(b1, b2)
		return
	
	# if either b1 or b2 don't exist in the banks above, check the reverse
	b1 = party_bot_bank.get_bot(bot_name1)
	b2 = digital_bot_bank.get_bot(bot_name2)
	
	assert(b1 != null and b2 != null)
	_swap_internal(b1, b2)
	
func _swap_internal(bot1: AvatarData, bot2: AvatarData):
	digital_bot_bank.remove_bot(bot1.avatar_name)
	party_bot_bank.remove_bot(bot2.avatar_name)
	
	digital_bot_bank.add_bot(bot2)
	party_bot_bank.add_bot(bot1)

func move_bot(container_src: ContainerType, container_dst: ContainerType, bot_name: String):
	if container_src == ContainerType.PARTY_BANK and container_dst == ContainerType.DIGITAL_BANK:
		var bot: AvatarData = party_bot_bank.get_bot(bot_name)
		party_bot_bank.remove_bot(bot_name)
		digital_bot_bank.add_bot(bot)
	elif container_src == ContainerType.DIGITAL_BANK and container_dst == ContainerType.PARTY_BANK:
		var bot: AvatarData = digital_bot_bank.get_bot(bot_name)
		digital_bot_bank.remove_bot(bot_name)
		party_bot_bank.add_bot(bot)
	# TODO(functional): swap between non-empty slot and empty slot
	elif container_src == ContainerType.PARTY_BANK and container_dst == ContainerType.PARTY_BANK:
		pass
	# TODO(functional): swap between non-empty slot and empty slot
	elif container_src == ContainerType.DIGITAL_BANK and container_dst == ContainerType.DIGITAL_BANK:
		pass
		
func _move_bot_internal(container_src: BotDataContainer, container_dst: BotDataContainer, bot_name: String):
	var bot: AvatarData = container_src.get_bot(bot_name)
	container_src.remove_bot(bot_name)
	container_dst.add_bot(bot)
	
	container_src.on_update_view.emit(container_src)
	container_dst.on_update_view.emit(container_dst)

func move_to_digital_bank(bot_name: String):
	_move_bot_internal(party_bot_bank, digital_bot_bank, bot_name)
	
func move_to_party(bot_name: String):
	_move_bot_internal(digital_bot_bank, party_bot_bank, bot_name)
