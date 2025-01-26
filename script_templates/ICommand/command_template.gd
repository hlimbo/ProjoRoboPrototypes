# meta-name: Command Pattern
# meta-description: Used for actions to be performed in turn-based games. Inspired from https://gameprogrammingpatterns.com/command.html 
# meta-default: true
# meta-space-indent: 4
extends ICommand

# Add commands your Actor will perform here in game
func execute(actor: Actor):
	print("command functionality here")
