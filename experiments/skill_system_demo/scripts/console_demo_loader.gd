extends Control
class_name ConsoleDemoLoader

# reference to the message node
@export var message_node: Resource
var counter: int = 1

func create_new_message(message: String):
	var msg = message_node.instantiate() as ConsoleDemoMessage
	self.add_child(msg)
	# move child to front so newest messages are shown from top to bottom
	# seems lackluster from Godot Engine as they don't have a way to reverse
	# view order of a list.... (an opportunity for them to add it to engine)
	self.move_child(msg, 0)
	
	message = "%d. %s" % [counter, message]
	msg.set_text_msg(message)
	counter += 1
