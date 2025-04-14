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
	MOVE_SIMPLE,
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

@export var cam_zoom_duration: float = 2.0
@export var cam_target_x_basis: Vector2
@export var cam_target_y_basis: Vector2
var zoom_scale: Vector2 = Vector2(1,1)

var old_position: Vector2 = Vector2(0, 0)
var target_position: Vector2 = Vector2(0,0) # origin

var old_center: Vector2
var new_center: Vector2
var cam_start_position: Vector2
var cam_end_position: Vector2


# Alternatively, I could just store a copy of the viewport canvas's original transform
# and set it back to it on reset
var original_cam_position: Vector2
# contains rotation and scale information
var original_x_basis: Vector2
var original_y_basis: Vector2

func _ready():
	assert(player_tutorial != null)
	assert(main_viewport != null)
	canvas_transform = main_viewport.canvas_transform
	assert(canvas_transform != null)
	
	original_cam_position = canvas_transform.origin
	original_x_basis = canvas_transform.x
	original_y_basis = canvas_transform.y
	
	# player's starting position when game starts
	last_player_pos = player_tutorial.global_position
	
	old_center = canvas_transform.origin + screen_size / 2.0
	
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
	old_position = target_position
	target_position = new_target.global_position + new_target.pivot_offset
	
	print("global position: ", target_position)
	print("position: ", new_target.position)
	
	# this is needed because when camera moves to target the movement happens relative to the camera's top-left pivot
	# screen_size / 2 centers the pivot 
	# subtract here as everything else but
	#cam_target_offset = new_target.global_position
	
	# the problem I got
	# I want to move the same amount of distance as it was if the camera had default zoom settings
	# always centered on screen
	
	# this assumes we stay on the same scale (1,0), (0,1)
	print("canvas transform x: ", canvas_transform.x)
	print("canvas_transform y: ", canvas_transform.y)
	
	# when zoomed in, you need to travel a larger distance
	# when zoomed out, you need to travel a smaller distance?

	# screen offset....
	# assuming camera is in (1,0), (0,1) basis vectors and zoom in is only option that can be applied
	var scaled_cam_size = Vector2(screen_size.x / canvas_transform.x.x, screen_size.y / canvas_transform.y.y)
	print("scaled cam size: ", scaled_cam_size)
	var midpoint: Vector2 = scaled_cam_size * 0.5 
	
	cam_start_position = canvas_transform.origin
	# subtract here because viewport as viewport moves left, everything else moves right
	cam_end_position = midpoint - target_position
	
	print("target position: ", target_position)
	
	print("cam start position: ", cam_start_position)
	print("cam end position: ", cam_end_position)
	
func zoom_camera(zoom_factor: float):
	if cam_state != CamTutorialState.NONE:
		return
	
	curr_cam_time = 0.0
	cam_state = CamTutorialState.ZOOM
	cam_target_x_basis = Vector2(zoom_factor, 0.0)
	cam_target_y_basis = Vector2(0.0, zoom_factor)
	
	# keep camera centered
	cam_start_position = canvas_transform.origin
	# compute center point of original camera size and scaled camera size
	old_center = screen_size / 2.0
	# division - zoom in | multiplication - zoom out
	var scaled_cam_size = Vector2(screen_size.x / cam_target_x_basis.x, screen_size.y / cam_target_y_basis.y)
	new_center = scaled_cam_size / 2.0
	print("new center: ", new_center)
	print("old center: ", old_center)
	print("target position: ", target_position)
	print("cam start position: ", cam_start_position)
	#cam_end_position = (new_center - old_center) + target_position
	#cam_end_position = new_center - target_position
	
func screenshake_camera(strength: float):
	pass
	
func reset():
	cam_state = CamTutorialState.NONE
	target_position = Vector2(0.0 , 0.0)
	zoom_scale = Vector2(1.0, 1.0)
	canvas_transform.origin = original_cam_position
	# reset rotation and scale to original values
	canvas_transform.x = original_x_basis
	canvas_transform.y = original_y_basis
	main_viewport.set_canvas_transform(canvas_transform)


func move(units: Vector2):
	curr_cam_time = 0.0
	cam_state = CamTutorialState.MOVE_SIMPLE
	cam_start_position = canvas_transform.origin
	cam_end_position = canvas_transform.origin + units

# the problem with this setup is that a camera can zoom and move at the same time
# so the question is in what order should the camera zoom and move in order to maintain a smooth transition?
func _process(delta: float):
	if cam_state == CamTutorialState.MOVE:
		var travel_ratio: float = curr_cam_time / cam_travel_duration
		canvas_transform.origin = lerp(cam_start_position, cam_end_position, travel_ratio)
		main_viewport.set_canvas_transform(canvas_transform)
		
		curr_cam_position = main_viewport.canvas_transform.origin
		curr_cam_time += delta
		
		if curr_cam_time >= cam_travel_duration:
			print("done moving to: ", cam_target.name)
			cam_state = CamTutorialState.NONE
			
	elif cam_state == CamTutorialState.ZOOM:
		var ratio: float = curr_cam_time / cam_zoom_duration
		canvas_transform.x = lerp(canvas_transform.x, cam_target_x_basis, ratio)
		canvas_transform.y = lerp(canvas_transform.y, cam_target_y_basis, ratio)
		# keep camera centered - shrink cam bounds
		canvas_transform.origin = lerp(cam_start_position, cam_end_position, ratio)
		main_viewport.set_canvas_transform(canvas_transform)
		
		curr_cam_time += delta
		if curr_cam_time >= cam_zoom_duration:
			print("done zooming")
			cam_state = CamTutorialState.NONE
			
	elif cam_state == CamTutorialState.MOVE_SIMPLE:
		var ratio: float = curr_cam_time / cam_travel_duration
		canvas_transform.origin = lerp(cam_start_position, cam_end_position, ratio)
		main_viewport.set_canvas_transform(canvas_transform)
		
		curr_cam_time += delta
		if curr_cam_time >= cam_travel_duration:
			print("done move simple")
			cam_state = CamTutorialState.NONE
