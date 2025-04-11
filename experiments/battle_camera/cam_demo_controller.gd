extends Control
class_name CamDemoController

### dependencies
@export var cam_tutorial: CameraTutorial
@export var targets: Array[ColorRect] = []
var target_index: int = 0

@onready var move_button: Button = $MoveButton
@onready var zoom_in_button: Button = $ZoomInButton
@onready var zoom_out_button: Button = $ZoomOutButton
@onready var screenshake_button: Button = $ScreenshakeButton


func _ready():
	var funk_map: Dictionary = {
		move_button: on_move,
		zoom_in_button: on_zoom_in,
		zoom_out_button: on_zoom_out,
		screenshake_button: on_screenshake
	}
	
	for btn in funk_map:
		btn.pressed.connect(funk_map[btn])
	

func on_move():
	assert(len(targets) > 0)
	
	cam_tutorial.move_camera(targets[target_index])
	# loop around targets
	target_index = (target_index + 1) % len(targets)
	
func on_zoom_in():
	pass
	
func on_zoom_out():
	pass
func on_screenshake():
	pass
