extends Area2D
class_name MobSelection

# this is the arrow that points to the enemy being selected
var target_selection: Sprite2D
@onready var col_shape: CollisionShape2D = $CollisionShape2D

var avatar: Avatar
@onready var root_node: Node2D = owner

signal on_target_hovered(avatar: Avatar, mob: MobSelection)
signal on_target_unhovered
signal on_target_clicked(damage_receiver: Avatar, damage_dealer: Avatar)


func _ready() -> void:		
	# hacky code - set in code the target_selection sprite2d graphic
	target_selection = get_node("../../TargetSelection")

func _on_mouse_entered() -> void:		
	# instantiate or make arrow visible above enemy
	# take enemy position and make it same as arrow asset
	if target_selection:
		target_selection.visible = true
		target_selection.position.x = global_position.x
		target_selection.position.y = global_position.y - (col_shape.shape.get_rect().size.y / 2)
	
	on_target_hovered.emit(avatar, self)

func _on_mouse_exited() -> void:
	if target_selection:
		target_selection.visible = false
	on_target_unhovered.emit()
	

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("left_mouse_click"):
		target_selection.visible = false
		on_target_clicked.emit()
