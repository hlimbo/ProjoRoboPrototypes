extends ICommand
class_name FleeCommand

# Add commands your Actor will perform here in game
func execute(actor: Actor):
	actor.begin_flee()
