extends ICommand
class_name AttackCommand

func execute(actor: Actor):
	actor.target = actor.original_target
	actor.start_motion()
