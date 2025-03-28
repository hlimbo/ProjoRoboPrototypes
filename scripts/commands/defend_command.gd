extends ICommand
class_name DefendCommand

# Add commands your Actor will perform here in game
func execute(actor: Actor):
	var avatar: Avatar = actor.avatar
	avatar.battle_state = Constants.Battle_State.EXECUTING_MOVE
	avatar.ui_battle_state_machine.transition_to(Constants.Battle_State.EXECUTING_MOVE)
	actor.active_battle_state_machine.transition_to(Constants.Active_Battle_State.DEFEND)
