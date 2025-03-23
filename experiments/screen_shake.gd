extends Node2D
class_name ScreenShake

enum SHAKE_PATTERN {
	RANDOM,
	NOISE,
}

# Adjust these parameters to modify the screen shake behavior
@export var shake_strength: float = 100.0
@export var shake_duration: float = 0.5
@export var shake_pattern: SHAKE_PATTERN = SHAKE_PATTERN.NOISE

# noise parameters
@export var noise_scale: float = 0.1
@export var shake_frequency: float = 30.0

# Private variables
var _shake_timer: float = 0.0
var _original_position: Vector2
var _noise: FastNoiseLite

func _ready():
	_original_position = self.position
	_noise = FastNoiseLite.new()
	_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	_noise.seed = randi()
	_noise.frequency = 0.01

func _process(delta: float):
	if _shake_timer > 0:
		_shake_timer -= delta
		match shake_pattern:
			SHAKE_PATTERN.RANDOM:
				shake_random()
			SHAKE_PATTERN.NOISE:
				shake_noise()
	else:
		self.position = _original_position
		

func start_shake(shake_strength: float = self.shake_strength, shake_duration: float = self.shake_duration):
	_shake_timer = shake_duration
	self.shake_strength = shake_strength
	self.shake_duration = shake_duration
	
func shake_random():
		self.position = _original_position + Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)

# samples pixels made using a pseudo randomly generated texture to offset the camera in different directions
func shake_noise():
	var time_since_engine_started: float = Time.get_ticks_msec()
	self.position = _original_position + Vector2(
		_noise.get_noise_2d(self.position.x * noise_scale, time_since_engine_started * shake_frequency) * shake_strength,
		_noise.get_noise_2d(self.position.y * noise_scale, time_since_engine_started * shake_frequency) * shake_strength
	)
