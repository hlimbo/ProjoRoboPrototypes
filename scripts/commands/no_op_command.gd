extends ICommand
class_name NoOpCommand

func execute(actor: Actor):
	var avatar: Avatar = actor.avatar
	avatar.battle_state = Constants.Battle_State.WAITING
	avatar.progress_ratio = 0
	
	BattleSignals.on_end_turn.emit(actor)
