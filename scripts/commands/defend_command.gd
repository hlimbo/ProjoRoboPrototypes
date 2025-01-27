extends ICommand
class_name DefendCommand

# Add commands your Actor will perform here in game
func execute(actor: Actor):
	var avatar: Avatar = actor.avatar
	
	avatar.progress_ratio = 1
	avatar.battle_state = avatar.Battle_State.EXECUTING_MOVE
	avatar.update_battle_state_text()
	
	actor.start_defend()
