extends Node

@export var audio_manager: AudioManager

@onready var play_button: Button = $PlayButton
@onready var play_button_2: Button = $PlayButton2
@onready var play_button_3: Button = $PlayButton3
@onready var play_bg: Button = $PlayBG
@onready var pause_bg: Button = $PauseBG
@onready var resume_bg: Button = $ResumeBG
@onready var stop_bg: Button = $StopBG

func _ready():
	play_button.pressed.connect(func(): audio_manager.play_audio_list("a1"))
	play_button_2.pressed.connect(func(): audio_manager.play_audio_list("a2"))
	play_button_3.pressed.connect(func(): audio_manager.play_audio_list("a3"))
	
	play_bg.pressed.connect(func(): audio_manager.play_audio_stream("BG"))
	pause_bg.pressed.connect(func(): audio_manager.pause_audio_stream("BG"))
	resume_bg.pressed.connect(func(): audio_manager.resume_audio_stream("BG"))
	stop_bg.pressed.connect(func(): audio_manager.stop_audio_stream("BG"))
	
