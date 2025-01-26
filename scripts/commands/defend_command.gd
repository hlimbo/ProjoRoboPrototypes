extends ICommand
class_name DefendCommand

# Add commands your Actor will perform here in game
func execute(actor: Actor):
	actor.start_defend()
