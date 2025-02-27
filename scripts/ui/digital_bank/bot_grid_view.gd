extends Control
class_name BotGridView

@export var actions_popup: ActionPopUpView
@export var action_label: Label

var bot_cell_res: Resource = load("res://nodes/ui/digital_bank/bot_cell.tscn")
var selected_cell: BotCellView = null

signal on_select(curr_cell: BotCellView)

func _ready():
	# TEMP: load in bot data
	var reader = BotCsvReader.new()
	var bots: Array = reader.read_csv_file("res://resources/csv/prototype_bots.txt", "\t")
	var bot_data: Array[AvatarData] = []
	for bot in bots:
		bot_data.append(bot as AvatarData)
		
	for bot in bot_data:
		var cell_view: BotCellView = bot_cell_res.instantiate()
		cell_view.initialize(bot.avatar_name, bot.level, bot.bot_type, bot.energy_type)
		cell_view.on_select.connect(on_select_cell)
		add_child(cell_view)
		
	# add empty cells
	for i in range(5):
		var cell_view: BotCellView = bot_cell_res.instantiate()
		cell_view.is_empty = true
		cell_view.on_select.connect(on_select_cell)
		add_child(cell_view)

func on_select_cell(curr_cell: BotCellView):
	on_select.emit(curr_cell)
