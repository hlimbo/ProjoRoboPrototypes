extends Label
class_name ConsoleDemoMessage

func set_text_msg(new_text: String):
	self.set_deferred("text", new_text)
