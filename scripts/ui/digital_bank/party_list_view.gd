extends Control
class_name PartyListView

@export var bot_inventory_systems: BotInventorySystems = BotInventorySystems

@export var party_list_size: int = 4

var bot_cell_res: Resource = load("res://nodes/ui/digital_bank/bot_cell.tscn")

signal on_select(curr_cell: BotCellView)

func _ready():
	for i in range(party_list_size):
		var cell_view: BotCellView = bot_cell_res.instantiate()
		cell_view.is_empty = true
		cell_view.on_select.connect(on_select_cell)
		cell_view.add_to_group(Constants.PARTY_MEMBER_SLOTS)
		cell_view.ordinal = i
		add_child(cell_view)
		
		cell_view.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		cell_view.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		
	bot_inventory_systems.on_party_view_update.connect(on_party_view_update)

func on_select_cell(curr_cell: BotCellView):
	on_select.emit(curr_cell)

func on_party_view_update(data_container: BotDataContainer):
	# TEMP - clear cells
	var children: Array = get_children()
	var child_count: int = len(children)
	while child_count > 0:
		var child = children.pop_back()
		child.queue_free()
		child_count -= 1
	
	# wait 1 frame until all child nodes are deleted at end of current frame
	await Engine.get_main_loop().process_frame
	
	# add all nodes back in
	var bots: Array = data_container.bot_table.values()
	bots.sort_custom(func(b1: AvatarData, b2: AvatarData): return b1.ordinal < b2.ordinal)
	
	var bot_index: int = 0
	var ordinal_index: int = 0
	child_count = 0
	while child_count < party_list_size:
		var cell_view: BotCellView = bot_cell_res.instantiate()
		if bot_index < len(bots):
			var avatar_data = bots[bot_index] as AvatarData
			if ordinal_index == avatar_data.ordinal:
				cell_view.initialize(avatar_data.avatar_name, avatar_data.level, avatar_data.bot_type, avatar_data.energy_type, avatar_data.avatar_icon)
				bot_index += 1
			else:
				cell_view.is_empty = true
		else:
			cell_view.is_empty = true
			
		
		cell_view.on_select.connect(on_select_cell)
		cell_view.add_to_group(Constants.PARTY_MEMBER_SLOTS)
		cell_view.ordinal = ordinal_index
		add_child(cell_view)
		# center the cell within the layout
		cell_view.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		cell_view.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		
		child_count += 1
		ordinal_index += 1
