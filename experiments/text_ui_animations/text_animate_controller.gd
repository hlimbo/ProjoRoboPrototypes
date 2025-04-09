extends Control
class_name TextAnimateController

@export var text_anim_player: TextAnimPlayer

@export var digit1: TextAnimPlayer
@export var digit2: TextAnimPlayer
@export var digit3: TextAnimPlayer

@onready var text_anim_1: Button = $VBoxContainer/TextAnim1
@onready var text_anim_2: Button = $VBoxContainer/TextAnim2
@onready var text_anim_3: Button = $VBoxContainer/TextAnim3
@onready var text_anim_4: Button = $VBoxContainer/TextAnim4
@onready var text_anim_5: Button = $VBoxContainer/TextAnim5
@onready var text_anim_6: Button = $VBoxContainer/TextAnim6


func _ready():
	var btn_to_pressed_functions: Dictionary = {
		text_anim_1: on_pressed1,
		text_anim_2: on_pressed2,
		text_anim_3: on_pressed3,
		text_anim_4: on_pressed4,
		text_anim_5: on_pressed5,
		text_anim_6: on_pressed6
	}
	
	for btn in btn_to_pressed_functions:
		btn.pressed.connect(btn_to_pressed_functions[btn])
	

func on_pressed1():
	text_anim_player.play_text_animation()
	
func on_pressed2():
	text_anim_player.play_text_animation2()
	
func on_pressed3():
	text_anim_player.play_text_animation3()
	
func pick_random_digits() -> Array[int]:
	# pick a random digit to pretend a monster is being damaged
	var d1 = randi_range(1, 9)
	var d2 = randi_range(1, 9)
	var d3 = randi_range(1, 9)
	return [d1, d2, d3]

func on_pressed4():
	var d: Array[int] = pick_random_digits()
	var delay_trail = 0.05
	digit1.play_text_animation(d[0])
	get_tree().create_timer(delay_trail).timeout.connect(func(): digit2.play_text_animation(d[1]))
	get_tree().create_timer(delay_trail * 2.0).timeout.connect(func(): digit3.play_text_animation(d[2]))
	
func on_pressed5():
	var d: Array[int] = pick_random_digits()
	var delay_trail = 0.05
	digit1.play_text_animation2(d[0])
	get_tree().create_timer(delay_trail).timeout.connect(func(): digit2.play_text_animation2(d[1]))
	get_tree().create_timer(delay_trail * 2.0).timeout.connect(func(): digit3.play_text_animation2(d[2]))

func on_pressed6():
	var d: Array[int] = pick_random_digits()
	var delay_trail = 0.05
	var jump_height: float = 100.0
	# sin is used here so that we get a curvy jump between digits
	var jump_height2: float = jump_height * sin(PI / 12.0)
	var jump_height3: float = jump_height * sin(PI / 8.0)
	digit1.play_text_animation3(d[0], jump_height)
	get_tree().create_timer(delay_trail).timeout.connect(func(): digit2.play_text_animation3(d[1], jump_height + jump_height2))
	get_tree().create_timer(delay_trail * 2.0).timeout.connect(func(): digit3.play_text_animation3(d[2], jump_height + jump_height3))
