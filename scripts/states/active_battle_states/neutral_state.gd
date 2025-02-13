extends IActorState
class_name NeutralState

# USE cases:
# - playing out an idle animation
# - playing out a quick time event like defending based on reaction input
# - doesn't do much here and that's by design to help compartmentalize code to reduce cognitive load
# - help pinpoint bugs/issues quicker

func on_enter():
	pass

func on_physics_enter():
	pass

func on_input(event: InputEvent):
	pass

func on_process(delta: float):
	pass

func on_physics_process(delta: float):
	pass
	
func on_exit():
	pass

func on_physics_exit():
	pass
