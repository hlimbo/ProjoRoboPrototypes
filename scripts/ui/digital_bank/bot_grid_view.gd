extends Control
class_name BotGridView

@export var bot_inventory_systems: BotInventorySystems = BotInventorySystems

@export var actions_popup: ActionPopUpView
@export var action_label: Label
@export var grid_size: int = 20

var bot_cell_res: Resource = load("res://nodes/ui/digital_bank/bot_cell.tscn")

signal on_select(curr_cell: BotCellView)

func _ready():
	init_grid_view()
	
	bot_inventory_systems.on_digital_bank_view_update.connect(update_grid_view)

func on_select_cell(curr_cell: BotCellView):
	on_select.emit(curr_cell)

func init_grid_view():
	var bots: Array = bot_inventory_systems.digital_bot_bank.bot_table.values()
	bots.sort_custom(func(b1: AvatarData, b2: AvatarData): return b1.ordinal < b2.ordinal)
	
	
	# add the bots in this grid based on the ordinal value they were given
	# ordinal determines where each bot would be positioned on the grid
	var bot_index: int = 0
	var ordinal_index: int = 0
	var child_count: int = 0
	while child_count < grid_size:
		var cell_view: BotCellView = bot_cell_res.instantiate()
		# no bots in the digital bank OR limit reached
		if bot_index >= len(bots):
			# add empty cell
			cell_view.is_empty = true
			cell_view.on_select.connect(on_select_cell)
			cell_view.add_to_group(Constants.DIGITAL_BANK_SLOTS)
		else:
			var bot: AvatarData = (bots[bot_index] as AvatarData)
			if ordinal_index == bot.ordinal:
				# add bot in position specified by its ordinal value
				cell_view.initialize(bot.avatar_name, bot.level, bot.bot_type, bot.energy_type)
				cell_view.on_select.connect(on_select_cell)
				cell_view.add_to_group(Constants.DIGITAL_BANK_SLOTS)
				bot_index += 1
			else:
				# add empty cell
				cell_view.is_empty = true
				cell_view.on_select.connect(on_select_cell)
				cell_view.add_to_group(Constants.DIGITAL_BANK_SLOTS)
		
		ordinal_index += 1
		add_child(cell_view)
		child_count += 1


func update_grid_view(bot_data_container: BotDataContainer):
	# temp - clear ui grid and remake it
	var children = get_children()
	var child_count = len(children)
	while child_count > 0:
		var child = children.pop_back()
		child.queue_free()
		child_count -= 1
	
	# Resume execution the next frame. - wait until child nodes are deleted at end of frame
	await Engine.get_main_loop().process_frame
	
	var bots: Array = bot_data_container.bot_table.values()
	bots.sort_custom(func(b1: AvatarData, b2: AvatarData): return b1.ordinal < b2.ordinal)
	
	
	# add the bots in this grid based on the ordinal value they were given
	# ordinal determines where each bot would be positioned on the grid
	var bot_index: int = 0
	var ordinal_index: int = 0
	child_count = 0
	while child_count < grid_size:
		var cell_view: BotCellView = bot_cell_res.instantiate()
		# no bots in the digital bank OR limit reached
		if bot_index >= len(bots):
			# add empty cell
			cell_view.is_empty = true
		else:
			var bot: AvatarData = (bots[bot_index] as AvatarData)
			if ordinal_index == bot.ordinal:
				# add bot in position specified by its ordinal value
				cell_view.initialize(bot.avatar_name, bot.level, bot.bot_type, bot.energy_type)
				bot_index += 1
			else:
				# add empty cell
				cell_view.is_empty = true
		
		cell_view.on_select.connect(on_select_cell)
		cell_view.add_to_group(Constants.DIGITAL_BANK_SLOTS)
		cell_view.ordinal = ordinal_index
		add_child(cell_view)
		
		child_count += 1
		ordinal_index += 1
		
	print("added new stuff")
