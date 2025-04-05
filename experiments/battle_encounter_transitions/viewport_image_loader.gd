extends TextureRect
class_name ViewportImageLoader

# shader uniform names coming from cinematic_shader.gshader
const light_percentage = "light_percentage"
const pixel_offset = "pixel_offset"
const fade_offset = "fade_offset"
const main_texture = "main_texture"

var shader_duration: float = 3.0
var curr_time: float = 0.0

@export var screenshot: Image
@export var shader: Shader
@export var screenshot_size: Vector2 = Vector2(1280, 720) # 428, 247

signal on_shader_playing_finished(anim_name: String)

func _ready():
	self.material = ShaderMaterial.new()
	load_shader(shader)
	self.set_process(false)

func is_shader_playing() -> bool:
	return self.is_processing() and curr_time < shader_duration

# capturing the image works in isolation.... maybe I need to load in the shader AFTER the image is captured?
func capture_image():
	# to ensure the frame is visible, processing must be enabled
	self.set_process(true)
	# wait til all drawing is complete for the processing frame
	await RenderingServer.frame_post_draw
	
	# this fills up viewport width and height in pixels which is defined in
	# Project Settings -> General -> Display -> Window
	screenshot = get_viewport().get_texture().get_image()
	assert(screenshot != null)
	
	# only resize the image if it's not fullscreen
	if screenshot_size.x < get_viewport().size.x and screenshot_size.y < get_viewport().size.y:
		screenshot.resize(screenshot_size.x, screenshot_size.y, Image.INTERPOLATE_TRILINEAR)
	
	var image_texture = ImageTexture.create_from_image(screenshot)
	assert(image_texture != null)
	print ("screenshot dimensions: %d x %d" % [screenshot.get_width(), screenshot.get_height()])
	print("image captured")
	
	self.texture = image_texture


func load_shader(shader_to_load: Shader):
	var shader_mat = self.material as ShaderMaterial
	shader_mat.shader = shader_to_load
	assert(shader_mat.shader != null)

func play_shader(duration_seconds: float):
	shader_duration = duration_seconds
	curr_time = 0.0
	
	self.reset_shader()
	self.visible = true
	self.set_process(true)
	# assign the screenshot taken
	var shader_mat = self.material as ShaderMaterial
	shader_mat.set_shader_parameter(main_texture, self.texture)
	
func reset_shader():
	var shader_mat = self.material as ShaderMaterial
	shader_mat.set_shader_parameter(light_percentage, 0)
	shader_mat.set_shader_parameter(pixel_offset, 0)
	shader_mat.set_shader_parameter(fade_offset, 0)
	self.visible = false
	self.curr_time = 0.0

func _input(event: InputEvent):
	if Input.is_action_just_pressed("screenshot"):
		capture_image()
		print("capturing image")

func _process(delta: float):
	if curr_time >= shader_duration:
		on_shader_playing_finished.emit()
		self.set_process(false)
		return
	
	var shader_mat = self.material as ShaderMaterial
	
	var part1_duration: float = 0.25 * shader_duration
	var part2_duration: float = 0.5 * shader_duration
	var percent1: float = curr_time / part1_duration
	var percent2: float = (curr_time - part1_duration) / part2_duration
	
	if curr_time < part1_duration:
		var light_value: float = lerpf(0.0, 1.0, percent1)
		var pixel_offset_value: float = lerpf(0.0, 0.005, percent1)
		shader_mat.set_shader_parameter(light_percentage, light_value)
		shader_mat.set_shader_parameter(pixel_offset, pixel_offset_value)
	else:
		var fade_offset_value: float = lerpf(0.0, 1.0, percent2)
		shader_mat.set_shader_parameter(fade_offset, fade_offset_value)
	
	curr_time += delta
