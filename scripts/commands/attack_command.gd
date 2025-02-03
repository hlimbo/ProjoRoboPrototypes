extends ICommand
class_name AttackCommand

# parameters needed
# attack target - other Actor
var target: Actor

func execute(actor: Actor):
	var avatar: Avatar = actor.avatar
	# move towards end of exe immediately
	avatar.progress_ratio = 1
	avatar.battle_state = Constants.Battle_State.EXECUTING_MOVE
	actor.start_motion(target)
