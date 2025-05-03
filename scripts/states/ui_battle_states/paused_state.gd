extends IAvatarState
# TODO: need better name... maybe Hit Stunned or Hurt State?
class_name PausedState

# TODO: add configurable pause timer
var pause_duration: float = 3 # seconds
var curr_duration: float = 0

func on_physics_enter():
	avatar.toggle_motion(true)

func on_input(event: InputEvent):
	pass

func on_process(delta: float):
	pass

func on_physics_process(delta: float):
	curr_duration += delta
	if absf(curr_duration - pause_duration) <= 0.001:
		avatar.ui_battle_state_machine.set_physics_process_tick(false)
		var old_battle_state: int = avatar.ui_battle_state_machine.old_state
		avatar.ui_battle_state_machine.transition_to(old_battle_state)

func on_physics_exit():
	avatar.ui_battle_state_machine.set_physics_process_tick(true)
	avatar.toggle_motion(false)
