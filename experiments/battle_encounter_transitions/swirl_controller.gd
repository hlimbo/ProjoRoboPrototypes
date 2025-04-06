extends BaseShaderController
class_name SwirlController

# uniform shader parameters
const fun = "fun"
const frequency = "frequency"

func reset():
	super()
	shader_mat.set_shader_parameter(fun, 0.0)
	shader_mat.set_shader_parameter(frequency, 0.0)

func on_update(_delta: float):
	var t: float = curr_time / play_duration
	var new_fun_value: float = lerpf(0.0, 1000.0, t)
	var new_freq_value: float = lerpf(0.0, 10.0, t)
	shader_mat.set_shader_parameter(fun, new_fun_value)
	shader_mat.set_shader_parameter(frequency, new_freq_value)
