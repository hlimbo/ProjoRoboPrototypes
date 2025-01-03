extends Area2D

# this is the arrow that points to the enemy being selected
var target_selection: Sprite2D
@onready var col_shape: CollisionShape2D = $CollisionShape2D

var mob_name: String

signal on_target_hovered(mob_name: String)
signal on_target_unhovered
signal on_target_clicked(mob_name: String)


func _ready() -> void:
	var parent: Node = get_parent()
	mob_name = name
	if parent != null:
		mob_name = parent.name
		
	# hacky code - set in code the target_selection sprite2d graphic
	target_selection = get_node("../../TargetSelection")
	print("ready target selection")

func _on_mouse_entered() -> void:		
	print("I hovered over: " + mob_name)
	# instantiate or make arrow visible above enemy
	# take enemy position and make it same as arrow asset
	if target_selection:
		target_selection.visible = true
		target_selection.position.x = global_position.x
		target_selection.position.y = global_position.y - (col_shape.shape.get_rect().size.y / 2)
	
	on_target_hovered.emit(mob_name)

func _on_mouse_exited() -> void:
	if target_selection:
		target_selection.visible = false
	on_target_unhovered.emit()
	

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("left_mouse_click"):
		print("clicked " + mob_name)
		on_target_clicked.emit(mob_name)
