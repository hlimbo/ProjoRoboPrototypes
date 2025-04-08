extends Control

# Dependency
@export var act_menu_controller: ActMenuController

@onready var horizontal_btn: Button = $VBoxContainer2/Intro/Horizontal
@onready var vertical_btn: Button = $VBoxContainer2/Intro/Vertical
@onready var scale_btn: Button = $VBoxContainer2/Intro/Scale
@onready var reset_btn: Button = $VBoxContainer2/Intro/Reset

@onready var horiz_check: CheckButton = $VBoxContainer2/AnimOptions/Horizontal/HorizCheck
@onready var vert_check: CheckButton = $VBoxContainer2/AnimOptions/Vertical/VertCheck
@onready var scale_check: CheckButton = $VBoxContainer2/AnimOptions/Scale/ScaleCheck

@export var is_horiz_animation: bool = false
@export var is_vert_animation: bool = false
@export var is_scale_animation: bool = false

func _ready():
	# default setting
	horiz_check.button_pressed = true;
	
	horizontal_btn.pressed.connect(func(): on_intro_anim_pressed("horizontal"))
	vertical_btn.pressed.connect(func(): on_intro_anim_pressed("vertical"))
	scale_btn.pressed.connect(func(): on_intro_anim_pressed("scale"))
	reset_btn.pressed.connect(func(): on_intro_anim_pressed("reset"))
	
	horiz_check.toggled.connect(func(toggle: bool): on_toggle("horizontal", toggle))
	vert_check.toggled.connect(func(toggle: bool): on_toggle("vertical", toggle))
	scale_check.toggled.connect(func(toggle: bool): on_toggle("scale", toggle))
	

func on_intro_anim_pressed(anim_type: String):
	act_menu_controller.play_intro(anim_type)

func on_toggle(anim_type: String, toggle: bool):
	if toggle:
		act_menu_controller.on_animation_switched(anim_type)
	else:
		act_menu_controller.on_animation_switched("no_animation")
	
