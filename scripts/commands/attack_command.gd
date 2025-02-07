extends ICommand
class_name AttackCommand

# parameters needed
# attack target - other Actor
var target: Actor
# takes in a string text parameter
var on_label_text_update: Callable

func execute(actor: Actor):
	var avatar: Avatar = actor.avatar
	# move towards end of exe immediately
	avatar.progress_ratio = 1
	avatar.battle_state = Constants.Battle_State.EXECUTING_MOVE
	actor.on_attack_damage_text_updated = on_label_text_update
	actor.start_motion(target)
	
