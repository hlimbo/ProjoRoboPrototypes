extends ColorRect
class_name SwirlController

# uniform shader parameters
const fun = "fun"
const frequency = "frequency"

var curr_time: float = 0
var shader_duration: float = 3
var shader_material: ShaderMaterial

signal on_shader_playing_finished

func _ready():
	set_process(false)
	self.shader_material = self.material as ShaderMaterial
	assert(self.shader_material != null)

func is_playing() -> bool:
	return is_processing() and curr_time < shader_duration

func play(duration_seconds: float):
	curr_time = 0
	shader_duration = duration_seconds
	
	set_process(true)

func reset():
	curr_time = 0
	shader_material.set_shader_parameter(fun, 0.0)
	shader_material.set_shader_parameter(frequency, 0.0)
	set_process(false)

func _process(delta: float):
	if curr_time >= shader_duration:
		on_shader_playing_finished.emit()
		set_process(false)
	
	var t: float = curr_time / shader_duration
	var new_fun_value: float = lerpf(0.0, 1000.0, t)
	var new_freq_value: float = lerpf(0.0, 10.0, t)
	shader_material.set_shader_parameter(fun, new_fun_value)
	shader_material.set_shader_parameter(frequency, new_freq_value)
	
	curr_time += delta
