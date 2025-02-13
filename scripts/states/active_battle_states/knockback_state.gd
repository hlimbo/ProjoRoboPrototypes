extends IActorState
class_name KnockbackState

func on_enter():
	# cancel pending actions such as basic attack or skill
	actor.on_cancel_move()

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
