extends ICommand
class_name BeginSkillCommand

# Add commands your Actor will perform here in game
func execute(actor: Actor):
	var avatar: Avatar = actor.avatar
	
	print("avatar %s start skill at time %d" % [avatar.name, Time.get_ticks_msec()])
	
	avatar.battle_state = Constants.Battle_State.PENDING_MOVE
	var wait_time: float = avatar.battle_timers.skill_timer.wait_time
	avatar._curr_speed = avatar.calculate_action_execution_speed(wait_time)
	avatar.battle_timers.skill_timer.start()
