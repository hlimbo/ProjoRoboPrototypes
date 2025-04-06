# meta-name: BaseShaderController
# meta-description: Used to play/manage shader animations through their uniform properties
# meta-default: true
# meta-space-indent: 4
extends BaseShaderController

func reset():
	super()
	# add reset logic here such as resetting uniform shader parameters

func play(duration_seconds: float):
	super(duration_seconds)
	
# handle shader animation logic here
func on_update(delta: float):
	pass
