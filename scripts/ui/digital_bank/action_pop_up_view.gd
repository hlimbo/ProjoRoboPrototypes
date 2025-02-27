extends Control
class_name ActionPopUpView

@onready var move_button: Button = $VBoxContainer/MoveButton
@onready var add_button: Button = $VBoxContainer/AddButton
@onready var view_button: Button = $VBoxContainer/ViewButton
@onready var close_button: Button = $VBoxContainer/CloseButton

@export var is_cell_empty: bool = false

signal on_move
signal on_add
signal on_view
signal on_close

func initialize():
	move_button.pressed.connect(func(): on_move.emit())
	add_button.pressed.connect(func(): on_add.emit())
	view_button.pressed.connect(func(): on_view.emit())
	close_button.pressed.connect(close)

# dependencies -- need to know if cell is empty or not
func set_buttons_visibility(is_cell_empty: bool):
	self.is_cell_empty = is_cell_empty
	
	if self.is_cell_empty:
		move_button.visible = false
		view_button.visible = false
		add_button.visible = true
	else:
		move_button.visible = true
		view_button.visible = true
		add_button.visible = false
		
func _ready():
	initialize()
	
func close():
	visible = false
	on_close.emit()
