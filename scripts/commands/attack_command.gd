extends ICommand
class_name AttackCommand

# parameters needed
# attack target - other Actor
var target: Actor

func execute(actor: Actor):
	# actor.target = actor.original_target
	actor.start_motion(target)
