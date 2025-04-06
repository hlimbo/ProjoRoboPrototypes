extends Control
class_name BaseShaderController

var shader_mat: ShaderMaterial
var curr_time: float = 0.0
var play_duration: float = 0.0

# is emitted when shader finishes its play
signal on_play_finished()

# used to determine if a shader is playing
# useful for preventing the same shader from getting played more than once 
func is_playing() -> bool:
	return is_processing() and curr_time < play_duration

# resets the uniform shader parameters back to default values
func reset():
	curr_time = 0.0
	set_process(false)

# plays the shader 
func play(duration_seconds: float):
	curr_time = 0.0
	play_duration = duration_seconds
	set_process(true)

# handle shader animation logic here
func on_update(delta: float):
	pass

func _ready():
	shader_mat = material as ShaderMaterial
	assert(shader_mat != null)
	set_process(false)
	
func _process(delta: float):
	if curr_time > play_duration:
		on_play_finished.emit()
		set_process(false)
		
	on_update(delta)
	
	curr_time += delta
