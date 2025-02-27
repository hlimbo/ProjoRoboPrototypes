extends Node

enum ContainerType {
	DIGITAL_BANK,
	PARTY_BANK,
}

var digital_bot_bank: BotDataContainer
var party_bot_bank: BotDataContainer

func _ready():
	digital_bot_bank = BotDataContainer.new()
	party_bot_bank = BotDataContainer.new()
	
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
