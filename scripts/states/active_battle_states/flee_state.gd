extends IActorState
class_name FleeState

var flee_time: float = 0

func on_enter():
	flee_time = 0

func on_physics_enter():
	pass

func on_input(event: InputEvent):
	pass

func on_process(delta: float):
	flee_time = clampf(flee_time + delta, 0, actor.flee_fade_time)
	var diff: float = (actor.flee_fade_time - flee_time) / actor.flee_fade_time if actor.flee_fade_time > 0 else 1
	actor.fadeout(diff)
	if diff == 0:
		actor.avatar.is_alive = false
		actor.active_battle_state_machine.set_process_tick(false)

func on_physics_process(delta: float):
	pass
	
func on_exit():
	pass

func on_physics_exit():
	pass
