extends Camera2D
class_name DerivedCamera2D

# Pros
# - don't need to deal with matrix math or be concerned about how to center a camera
# --- this seems to be built in with the Camera2D class already
# - zooming in / out and translating the camera from 1 target to the next perserves camera ratios
enum DerivedCameraOptions {
	ZOOM,
	MOVE,
	SHAKE,
	NONE,
}

# Dependencies
@export var perlin_noise_generator: PerlinNoiseGenerator


var curr_time: float = 0.0
@export var zoom_duration: float = 2.0
@export var move_duration: float = 2.0
@export var shake_duration: float = 3.0
var old_position: Vector2
var target_position: Vector2
var start_zoom = Vector2(1.0, 1.0)
var target_zoom = Vector2(1.0, 1.0)

# screenshake
@export var strength = 100.0
var random_vel: Vector2
var is_random_dir_picked: bool
var perlin_noise: Array[Vector2] = []
var perlin_index: int = 0
@export var noise_factor: int = 32

var camera_option = DerivedCameraOptions.NONE

func zoom_camera(zoom_factor: float):
	curr_time = 0.0
	start_zoom = Vector2(self.zoom.x, self.zoom.y)
	target_zoom = zoom_factor * Vector2(self.zoom.x, self.zoom.y)
	camera_option = DerivedCameraOptions.ZOOM

func move_camera(target: ColorRect):
	curr_time = 0.0
	camera_option = DerivedCameraOptions.MOVE
	old_position = self.position
	target_position = target.position

func pick_random_direction() -> Vector2:
	var strength: float = 10.0
	# pick random x value
	var rand_x: float = 2.0 * randf() - 1.0 # go from -1 to 1
	# pick random y value
	var rand_y: float = 2.0 * randf() - 1.0
	# store it in a vector2 representing direction and normalize it
	return Vector2(rand_x, rand_y).normalized()

func screen_shake():
	curr_time = 0.0
	old_position = self.position
	camera_option = DerivedCameraOptions.SHAKE
	perlin_noise = perlin_noise_generator.get_noise_2d(noise_factor)
	

func apply_noise(n: int):
	if !is_random_dir_picked:
		var noise_value: Vector2 = perlin_noise[perlin_index]
		random_vel = strength * noise_value
		self.position = self.position + random_vel
		perlin_index = (perlin_index + 1) % n
		is_random_dir_picked = true
	else:
		self.position = self.position - random_vel
		is_random_dir_picked = false

func cam_shake_offset():
	if !is_random_dir_picked:
		# pick random direction to move towards
		random_vel = strength * pick_random_direction()
		self.position = self.position + random_vel
		is_random_dir_picked = true
	else:
		is_random_dir_picked = false
		# move back to original position
		self.position = self.position - random_vel

# strength = 50
# shake duration = 3
func cam_shake_sine(time_passed: float):
	var amplitude: float = strength
	var frequency: float = 16.0 * TAU
	var horizontal_offset: float = 0 # PI / 2
	
	# math reminder sin range (-1, 1) which is good use case for direction
	var x: float = amplitude * cos(time_passed * frequency)
	var y: float = amplitude * sin(time_passed * frequency + horizontal_offset)
	var dir = Vector2(x,y).normalized()
	random_vel = strength * dir
	self.position = self.position + random_vel

func reset():
	self.zoom = Vector2(1.0, 1.0)
	self.position = old_position
	camera_option = DerivedCameraOptions.NONE
	curr_time = 0.0

func _process(delta: float):
	
	
	if camera_option == DerivedCameraOptions.ZOOM:
		var ratio: float = curr_time / zoom_duration
		self.zoom = lerp(start_zoom, target_zoom, ratio)
		
		curr_time += delta
		if curr_time >= zoom_duration:
			camera_option = DerivedCameraOptions.NONE
	elif camera_option == DerivedCameraOptions.MOVE:
		var ratio: float = curr_time / move_duration
		self.position = lerp(old_position, target_position, ratio)
		
		curr_time += delta
		if curr_time >= move_duration:
			camera_option = DerivedCameraOptions.NONE
	elif camera_option == DerivedCameraOptions.SHAKE:
		# perlin noise
		#apply_noise(noise_factor)
		# random offsets
		cam_shake_offset()
		# sine cos waves
		#cam_shake_sine(curr_time)
		curr_time += delta
		if curr_time >= shake_duration:
			camera_option = DerivedCameraOptions.NONE
			self.position = old_position
