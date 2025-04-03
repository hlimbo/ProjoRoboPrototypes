extends TextureRect
class_name ViewportImageLoader

#1. Create a TextureRect Node
#2. Set its texture property to be an ImageTexture
#3. assign ImageTexture set_image function to be the image captured from get_viewport().get_texture().get_image()
#4. apply Material Property found on TextureRect to be a ShaderMaterial
#5. load shader from file (where the blur effect shader comes into play)
#
#6 apply uniform variables exposed from shader to update the shader per from in _process()

@export var screenshot: Image
@export var shader: Shader

func _ready():
	self.material = ShaderMaterial.new()

# capturing the image works in isolation.... maybe I need to load in the shader AFTER the image is captured?
func capture_image():
	# wait til all drawing is complete for the processing frame
	await RenderingServer.frame_post_draw
	
	# this fills up viewport width and height in pixels which is defined in
	# Project Settings -> General -> Display -> Window
	screenshot = get_viewport().get_texture().get_image()
	assert(screenshot != null)
	
	screenshot.resize(300, 300, Image.INTERPOLATE_TRILINEAR)
	
	var image_texture = ImageTexture.create_from_image(screenshot)
	assert(image_texture != null)
	print ("screenshot dimensions: %d x %d" % [screenshot.get_width(), screenshot.get_height()])
	print("image captured")
	
	self.texture = image_texture
	load_shader(shader)


func load_shader(shader_to_load: Shader):
	var shader_mat = self.material as ShaderMaterial
	shader_mat.shader = shader_to_load
	assert(shader_mat.shader != null)
	
# can be its own script to update the uniform properties of a shader over several frames
func update_shader_properties():
	pass

func _input(event: InputEvent):
	if Input.is_action_just_pressed("screenshot"):
		capture_image()
		print("capturing image")
