extends Area2D
class_name MobSelection

# this is the arrow that points to the enemy being selected
@onready var target_selection: Sprite2D = $SelectionArrow
@onready var col_shape: CollisionShape2D = $CollisionShape2D

var actor: Actor
@onready var root_node: Node2D = owner

signal on_target_hovered(actor: Actor, mob: MobSelection)
signal on_target_unhovered
signal on_target_clicked(damage_receiver: Actor, damage_dealer: Actor)

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)


func _on_mouse_entered() -> void:
	if target_selection:
		target_selection.visible = true
	on_target_hovered.emit(actor, self)

func _on_mouse_exited() -> void:
	if target_selection:
		target_selection.visible = false
	on_target_unhovered.emit()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select"):
		target_selection.visible = false
		# why is this connection missing stuff?
		var connections = on_target_clicked.get_connections()
		on_target_clicked.emit()
