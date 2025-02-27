extends Control
class_name DigitalBankController

enum Action {
	MOVE,
	ADD,
	VIEW,
	NO_OP,
}

@export var bot_inventory_systems: BotInventorySystems = BotInventorySystems

@export var curr_action: Action = Action.NO_OP

@onready var actions_popup: ActionPopUpView = $ActionsPopup
@onready var action_label: Label = $ActionLabel
@onready var grid_container: BotGridView = $GridSlots/GridContainer
@onready var party_member_slots: PartyListView = $PartyMemberSlots/VBoxContainer/PartyListView
@onready var bot_info: BotDescriptionView = $BotPreview/BotInfo

var selected_cell: BotCellView = null
var selected_cell2: BotCellView = null

func _ready():
	actions_popup.on_add.connect(on_add_popup)
	actions_popup.on_move.connect(on_move_popup)
	actions_popup.on_view.connect(on_view_popup)
	actions_popup.on_close.connect(on_close_popup)
	grid_container.on_select.connect(on_select)
	party_member_slots.on_select.connect(on_select)
	
func on_select(curr_cell: BotCellView):
	# if same cell, no operations required
	if selected_cell == curr_cell:
		return
	
	# let's try using groups to determine where the cell originates from
	# so that I know how to move data between 1 data structure to the next
	# as well as reflect those changes on the view layer
	match curr_action:
		Action.MOVE:
			selected_cell2 = curr_cell
			# case 1 - swap between 2 bots on the same grid
			if selected_cell.is_in_group(Constants.DIGITAL_BANK_SLOTS) and selected_cell2.is_in_group(Constants.DIGITAL_BANK_SLOTS):
				bot_inventory_systems.swap_bots_in_digital_bank(selected_cell.bot_name, selected_cell2.bot_name)
			# case 2 - swap between 2 bots in party layout
			elif selected_cell.is_in_group(Constants.PARTY_MEMBER_SLOTS) and selected_cell2.is_in_group(Constants.PARTY_MEMBER_SLOTS):
				bot_inventory_systems.swap_bots_in_party(selected_cell.bot_name, selected_cell2.bot_name)
			# case 3 - swap bots between grid and party layout
			elif selected_cell.is_in_group(Constants.DIGITAL_BANK_SLOTS) and selected_cell2.is_in_group(Constants.PARTY_MEMBER_SLOTS):
				pass
			# case 4 - swap bots betweens party and grid layout
			elif selected_cell.is_in_group(Constants.PARTY_MEMBER_SLOTS) and selected_cell2.is_in_group(Constants.DIGITAL_BANK_SLOTS):
				pass
				
			curr_action = Action.NO_OP
			selected_cell.self_modulate = Color.WHITE
			selected_cell2.self_modulate = Color.WHITE
			selected_cell = null
			
		Action.ADD:
			selected_cell2 = curr_cell
			
			# if empty cell is picked to Add, skip it -- a better way to handle this is to 
			# filter out which cells are selectable before passing it down to this function
			if selected_cell2.is_empty:
				curr_action = Action.NO_OP
				selected_cell.self_modulate = Color.WHITE
				selected_cell2.self_modulate = Color.WHITE
				selected_cell = null
				return
			
			
			# case 1 - add bot from grid layout to list layout
			if selected_cell.is_in_group(Constants.PARTY_MEMBER_SLOTS) and selected_cell2.is_in_group(Constants.DIGITAL_BANK_SLOTS):
				bot_inventory_systems.move_to_party(selected_cell2.bot_name, selected_cell.ordinal)
			# case 2 - add bot from list layout to grid layout
			elif selected_cell.is_in_group(Constants.DIGITAL_BANK_SLOTS) and selected_cell2.is_in_group(Constants.PARTY_MEMBER_SLOTS):
				bot_inventory_systems.move_to_digital_bank(selected_cell2.bot_name, selected_cell.ordinal)
			
			curr_action = Action.NO_OP
			selected_cell.self_modulate = Color.WHITE
			selected_cell2.self_modulate = Color.WHITE
			selected_cell = null
			
			
		Action.NO_OP:
			on_highlight_cell(curr_cell)
		Action.VIEW:
			on_highlight_cell(curr_cell)

func on_highlight_cell(curr_cell: BotCellView):
	# unhighlight previous selected cell
	if is_instance_valid(selected_cell):
		selected_cell.self_modulate = Color.WHITE
	
	selected_cell = curr_cell
	
	if is_instance_valid(actions_popup):
		var offset = Vector2(-50, 50)
		
		actions_popup.visible = true
		actions_popup.set_buttons_visibility(curr_cell.is_empty)
		actions_popup.global_position = curr_cell.global_position + offset

func on_move_popup():
	action_label.visible = true
	action_label.text = "Action: move mode"
	curr_action = Action.MOVE
	actions_popup.visible = false

func on_add_popup():
	action_label.visible = true
	action_label.text = "Action: add mode"
	curr_action = Action.ADD
	actions_popup.visible = false

func on_view_popup():
	action_label.visible = true
	action_label.text = "Action: view mode"
	actions_popup.visible = false
	curr_action = Action.VIEW
	
	if is_instance_valid(selected_cell):
		bot_info.initialize(selected_cell.bot_name, selected_cell.level, selected_cell.bot_type, selected_cell.energy_type)

func on_close_popup():
	if is_instance_valid(selected_cell):
		selected_cell.self_modulate = Color.WHITE
		selected_cell = null
		
	action_label.visible = false
	curr_action = Action.NO_OP
