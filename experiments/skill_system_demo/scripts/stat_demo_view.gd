# https://docs.godotengine.org/en/4.3/tutorials/plugins/running_code_in_the_editor.html
@tool
extends Control
class_name StatDemoView

@export var label: String = "Health"
@export var value: float = 0.0
@onready var stat_value: Label = $StatValue
@onready var stat_label: Label = $StatLabel

func set_stat_value(new_value: float):
	self.value = new_value
	self.stat_value.text = "%d" % int(round(self.value))
	

# example of allowing text to be editted dynamically within godot editor
func _process(_delta: float):
	if !is_instance_valid(stat_value) or !is_instance_valid(stat_label):
		return
		
	editor_update_fields()

func editor_update_fields():
	self.stat_label.text = self.label
	self.stat_value.text = "%d" % int(round(self.value))
	# this is to request godot to redraw the new label value being rendered on screen
	self.queue_redraw()
