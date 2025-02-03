# chatgpt generated code
extends Control

@export var radius: float = 150  # Distance from pivot
@export var rotation_speed: float = 0.2  # Smooth transition speed
@export var rotation_duration: float = 0.3  # Smooth transition time

@onready var actions: Array = [
	$item1,
	$item2,
	$item3,
	$item4
]
var selected_index: int = 0
var target_angle: float = 0.0

func _ready():
	actions = get_children()  # Get all action buttons
	arrange_buttons()

func arrange_buttons():
	var action_count = actions.size()
	for i in range(action_count):
		var angle = i * (2 * PI / action_count)
		var x = cos(angle) * radius
		var y = sin(angle) * radius
		actions[i].position = Vector2(x, y) + size / 2  # Centered positioning

func _process(delta):
	rotation = lerp_angle(rotation, target_angle, rotation_speed)

func select_next():
	selected_index = (selected_index + 1) % actions.size()
	update_selection()

func select_previous():
	selected_index = (selected_index - 1 + actions.size()) % actions.size()
	update_selection()

func update_selection():
   # Animate rotation using Tween
	var tween = get_tree().create_tween()
	var action_count = actions.size()
	for i in range(action_count):
		var target_angle = (i - selected_index) * (2 * PI / action_count)  # Adjust for new selection
		var target_position = Vector2(cos(target_angle) * radius, sin(target_angle) * radius) + size / 2

		# Tween position to smoothly move the buttons
		tween.tween_property(actions[i], "position", target_position, rotation_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	highlight_selected()

func highlight_selected():
	for i in range(actions.size()):
		var is_selected = (i == selected_index)
		var target_scale = Vector2(5,5) if is_selected else Vector2(1, 1)  # Enlarge selected item

		# Animate scaling with Tween
		var tween = get_tree().create_tween()
		tween.tween_property(actions[i], "scale", target_scale, rotation_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		actions[i].modulate = Color(1, 1, 1, 1) if is_selected else Color(1, 1, 1, 0.5)  # Highlight selection

func _unhandled_input(event):
	if event.is_action_pressed("ui_right"):
		select_next()
	elif event.is_action_pressed("ui_left"):
		select_previous()
