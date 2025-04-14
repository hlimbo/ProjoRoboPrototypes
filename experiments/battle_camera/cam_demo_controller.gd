extends Control
class_name CamDemoController

### dependencies
@export var cam_tutorial: CameraTutorial
@export var derived_cam: DerivedCamera2D
@export var targets: Array[ColorRect] = []
var target_index: int = 0

@onready var move_button: Button = $MoveButton
@onready var zoom_in_button: Button = $ZoomInButton
@onready var zoom_out_button: Button = $ZoomOutButton
@onready var screenshake_button: Button = $ScreenshakeButton
@onready var reset_button: Button = $ResetButton

@onready var move_up: Button = $MoveUp
@onready var move_down: Button = $MoveDown
@onready var move_left: Button = $MoveLeft
@onready var move_right: Button = $MoveRight

@export var move_units: float = 100.0

func _ready():
	var funk_map: Dictionary = {
		move_button: on_move,
		zoom_in_button: on_zoom_in,
		zoom_out_button: on_zoom_out,
		screenshake_button: on_screenshake,
		reset_button: on_reset,
		# opposite
		move_up: func(): on_move2(Vector2(0, move_units)),
		move_down: func(): on_move2(Vector2(0, -move_units)),
		move_left: func(): on_move2(Vector2(move_units, 0.0)),
		move_right: func(): on_move2(Vector2(-move_units, 0.0))
	}
	
	for btn in funk_map:
		btn.pressed.connect(funk_map[btn])
	

func on_move():
	assert(len(targets) > 0)
	
	#cam_tutorial.move_camera(targets[target_index])
	derived_cam.move_camera(targets[target_index])
	# loop around targets
	target_index = (target_index + 1) % len(targets)

func on_move2(units: Vector2):
	cam_tutorial.move(units)

func on_zoom_in():
	derived_cam.zoom_camera(1.5)
	#cam_tutorial.zoom_camera(2.0)
	
func on_zoom_out():
	derived_cam.zoom_camera(0.5)
	#cam_tutorial.zoom_camera(0.95)

func on_screenshake():
	derived_cam.screen_shake()
	
func on_reset():
	#cam_tutorial.reset()
	derived_cam.reset()
