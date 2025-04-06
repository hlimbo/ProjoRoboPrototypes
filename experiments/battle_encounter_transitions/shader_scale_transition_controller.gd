extends BaseShaderController
# uniform shader parameters
const half_box_area = "half_box_area"

func reset():
	super()
	self.shader_mat.set_shader_parameter(half_box_area, 0.0)

func on_update(_delta: float):
	var half_box_area_value: float = lerpf(0.0, 0.5, self.curr_time / self.play_duration)
	self.shader_mat.set_shader_parameter(half_box_area, half_box_area_value)
