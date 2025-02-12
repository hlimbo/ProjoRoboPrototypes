extends ICommand
class_name NoOpCommand

func execute(actor: Actor):
	var avatar: Avatar = actor.avatar
	avatar.battle_state = Constants.Battle_State.WAITING
	avatar.progress_ratio = 0
	avatar.ui_battle_state_machine.transition_to(Constants.Battle_State.WAITING)
	
	BattleSignals.on_end_turn.emit(actor)
