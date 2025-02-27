extends Control
class_name DigitalBankController

@onready var actions_popup: ActionPopUpView = $ActionsPopup
@onready var action_label: Label = $ActionLabel
@onready var grid_container: BotGridView = $GridSlots/GridContainer

var selected_cell: BotCellView = null

func _ready():
	actions_popup.on_add.connect(on_add_popup)
	actions_popup.on_move.connect(on_move_popup)
	actions_popup.on_view.connect(on_view_popup)
	actions_popup.on_close.connect(on_close_popup)
	grid_container.on_select.connect(on_select)
	
func on_select(curr_cell: BotCellView):
	# if same cell, no operations required
	if selected_cell == curr_cell:
		return
		
	if is_instance_valid(selected_cell):
		selected_cell.self_modulate = Color.WHITE
	
	print("cell selected")
	selected_cell = curr_cell
	
	if is_instance_valid(actions_popup):
		var offset = Vector2(-50, 50)
		
		actions_popup.visible = true
		actions_popup.set_buttons_visibility(curr_cell.is_empty)
		actions_popup.global_position = curr_cell.global_position + offset
		#actions_popup.z_index = 10

func on_move_popup():
	print("move")
	action_label.visible = true
	action_label.text = "Action: move mode"
		
	actions_popup.visible = false

func on_add_popup():
	print("add")

	action_label.visible = true
	action_label.text = "Action: add mode"
		
	actions_popup.visible = false

func on_view_popup():
	print("view")
	action_label.visible = true
	action_label.text = "Action: view mode"
		
	actions_popup.visible = false

func on_close_popup():
	if is_instance_valid(selected_cell):
		selected_cell.self_modulate = Color.WHITE
		selected_cell = null
		
	action_label.visible = false
