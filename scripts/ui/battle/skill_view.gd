extends Control
class_name SkillView

@onready var button: Button = $ButtonContainer/Button
@onready var cost_label: Label = $CostLabel

# takes in a skill parameter
var on_button_pressed: Callable
var skill: Skill

func init(new_skill: Skill):
	button.text = new_skill.name
	cost_label.text = str(new_skill.get_modifier("energy-cost").stat_value) + " SRP"
	self.skill = new_skill

func connect_button(btn_pressed: Callable):
	on_button_pressed = btn_pressed
	button.pressed.connect(on_button_pressed.bind(skill))

# remove all callable functions connected to the pressed signal
func disconnect_button():
	for connection in button.pressed.get_connections():
		button.pressed.disconnect(connection)
