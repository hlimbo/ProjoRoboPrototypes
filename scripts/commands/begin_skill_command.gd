extends ICommand
class_name BeginSkillCommand

# Add commands your Actor will perform here in game
func execute(actor: Actor):
	var avatar: Avatar = actor.avatar
	print("avatar %s start skill at time %d" % [avatar.name, Time.get_ticks_msec()])
	avatar.battle_state = Constants.Battle_State.PENDING_MOVE
	avatar.ui_battle_state_machine.transition_to(Constants.Battle_State.PENDING_MOVE)
