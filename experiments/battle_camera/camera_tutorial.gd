# following tutorials: GDQuest
# https://www.youtube.com/watch?v=xUSEeXDtwIw
# https://www.youtube.com/watch?v=FkxZECaD5To
extends Node2D
class_name CameraTutorial

@onready var screen_size = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
)
@onready var last_player_pos: Vector2

enum CamTutorialState {
	MOVE,
	ZOOM,
	SCREENSHAKE,
	NONE,
}

@export var cam_state: CamTutorialState = CamTutorialState.NONE
@export var curr_cam_position: Vector2

### Dependencies
@onready var main_viewport: Viewport = get_viewport()
@onready var canvas_transform: Transform2D
@export var player_tutorial: PlayerTutorial


@export var cam_travel_duration: float = 3.0
@export var curr_cam_time: float = 0.0
@export var cam_target_offset: Vector2
@export var cam_target: ColorRect

func _ready():
	assert(player_tutorial != null)
	assert(main_viewport != null)
	canvas_transform = main_viewport.canvas_transform
	assert(canvas_transform != null)
	
	# player's starting position when game starts
	last_player_pos = player_tutorial.global_position
	
	# what these 3 lines of code are doing is
	# obtaining the matrix that represents the scale, rotation, skew, and translation
	# 1st one represents its x-axis
	# 2nd one represents its y-axis
	# 3rd one represents is global position
	
	# aligned with the global axis
	# x is parallel to global x-axis
	# x = [1,0] x-vector
	# y is parallel to global y-axis
	# y = [0, 1] y-vector
	# position - relative to the global origin (0,0)
	# matrix[2] = [x,y]
	# contains matrix of coordinate system
	# 2nd element in canvas_transform is the position (centered around player position)
	# canvas_transform[2] = screen_size / 2 # - last_player_pos
	main_viewport.set_canvas_transform(canvas_transform)
	curr_cam_position = main_viewport.canvas_transform.origin
	
	player_tutorial.move.connect(update_camera)

# this get's called whenever player moves
func update_camera():
	var player_offset = last_player_pos - player_tutorial.global_position
	last_player_pos = player_tutorial.global_position
	
	# apply the player offset to this viewport's transform to move the camera to follow player
	canvas_transform[2] += player_offset
	main_viewport.set_canvas_transform(canvas_transform)
	
	# print out the computed player offset
	return player_offset

func move_camera(new_target: ColorRect):
	cam_state = CamTutorialState.MOVE
	curr_cam_time = 0.0
	cam_target = new_target
	# this is needed because when camera moves to target the movement happens relative to the camera's top-left pivot
	# screen_size / 2 centers the pivot 
	# subtract here as everything else but
	#cam_target_offset = new_target.global_position
	cam_target_offset = screen_size / 2  - new_target.global_position

	
func zoom_camera(zoom_factor: float):
	pass
	
func screenshake_camera(strength: float):
	pass
	
func _process(delta: float):
	if cam_state == CamTutorialState.MOVE:
		var cam_position: Vector2 = canvas_transform.origin
		var travel_ratio: float = curr_cam_time / cam_travel_duration
		canvas_transform.origin = lerp(cam_position, cam_target_offset, travel_ratio)
		main_viewport.set_canvas_transform(canvas_transform)
		
		curr_cam_position = main_viewport.canvas_transform.origin
		
		curr_cam_time += delta
		
		if curr_cam_time >= cam_travel_duration:
			print("done moving to: ", cam_target.name)
			cam_state = CamTutorialState.NONE
