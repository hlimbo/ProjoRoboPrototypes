extends Control
class_name ActionPopUpView

@onready var move_button: Button = $VBoxContainer/MoveButton
@onready var add_button: Button = $VBoxContainer/AddButton
@onready var view_button: Button = $VBoxContainer/ViewButton

@export var is_cell_empty: bool = false

signal on_move
signal on_add
signal on_view

# dependencies -- need to know if cell is empty or not
func initialize(is_cell_empty: bool):
	self.is_cell_empty = is_cell_empty
	
	if self.is_cell_empty:
		move_button.visible = false
		add_button.visible = true
	else:
		move_button.visible = true
		add_button.visible = false
		
	move_button.pressed.connect(func(): on_move.emit())
	add_button.pressed.connect(func(): on_add.emit())
	view_button.pressed.connect(func(): on_view.emit())
