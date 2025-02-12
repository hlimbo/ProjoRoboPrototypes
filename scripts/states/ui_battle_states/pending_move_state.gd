extends IAvatarState
class_name PendingMoveState

func on_enter():
	# which pending move is being waited on?
	# how long should each one be awaited on?
	var wait_time: float = avatar.battle_timers.skill_timer.wait_time
	avatar._curr_speed = avatar.calculate_action_execution_speed(wait_time)
	avatar.battle_timers.skill_timer.start()
