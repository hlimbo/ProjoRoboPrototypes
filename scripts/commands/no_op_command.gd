extends ICommand
class_name NoOpCommand

func execute(actor: Actor):
	var avatar: Avatar = actor.avatar
	avatar.battle_state = Constants.Battle_State.EXECUTING_MOVE
	avatar.progress_ratio = 1
	
	BattleSignals.on_end_turn.emit(actor)
