extends Control
class_name PartyListView

@export var party_list_size: int = 4
@onready var list_container: VBoxContainer = $VBoxContainer

var bot_cell_res: Resource = load("res://nodes/ui/digital_bank/bot_cell.tscn")

signal on_select(curr_cell: BotCellView)

func _ready():
	for i in range(party_list_size):
		var cell_view: BotCellView = bot_cell_res.instantiate()
		cell_view.is_empty = true
		cell_view.on_select.connect(on_select_cell)
		list_container.add_child(cell_view)
		
		cell_view.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		cell_view.size_flags_vertical = Control.SIZE_SHRINK_CENTER

func on_select_cell(curr_cell: BotCellView):
	on_select.emit(curr_cell)
