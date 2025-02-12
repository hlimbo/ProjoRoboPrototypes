extends IAvatarState
class_name UiKnockbackState

var curr_time: float = 0
# TODO: these should be passed as parameters as different moves will have different knockback values
var push_back_amount: float = 1.0
var knockback_duration_sec: float = 1.5
var pause_duration_sec: float = 1.0

func on_enter():
	# cancel any pending skills
	print("move pending by %s is cancelled" % avatar.curr_stats.name)
	avatar.battle_timers.skill_timer.stop()
	Utility.disconnect_all_signal_connections(avatar.battle_timers.skill_timer.timeout)

func on_physics_enter():
	avatar.is_knocked_back = true
	# disable monitoring so that it does not trigger a start turn signal event
	avatar.area_2d.monitoring = false
	avatar.is_moving_forward = false
	
	curr_time = 0.0
	avatar._curr_speed = push_back_amount / knockback_duration_sec

func on_physics_process(delta: float):
	curr_time += delta
	if absf(curr_time - knockback_duration_sec) <= 0.001:
		avatar.toggle_motion(true)
	elif absf(curr_time - (knockback_duration_sec + pause_duration_sec)) <= 0.001:
		# stop physics process until it transitions to a new state
		avatar.ui_battle_state_machine.set_physics_process_tick(false)
		# ASSUMPTION: all knockbacks will push avatar out of pending move and executing move states
		avatar.ui_battle_state_machine.transition_to(Constants.Battle_State.WAITING)
		
func on_physics_exit():
	avatar.ui_battle_state_machine.set_physics_process_tick(true)
	avatar.toggle_motion(true)
	avatar.is_knocked_back = false
	# re-enable this so avatar can start their turn -- assuming you get pushed out of the exe rectangle
	avatar.area_2d.monitoring = true
	# assuming avatar gets pushed out of pending move or starting turn... reset movement speed back to waiting speed
	avatar._curr_speed = avatar.move_speed
	avatar.is_moving_forward = true
