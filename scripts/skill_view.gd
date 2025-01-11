extends Node
class_name SkillView

@onready var button: Button = $ButtonContainer/Button
@onready var cost_label: Label = $CostLabel

func init(skill: Skill):
	button.text = skill.name
	cost_label.text = str(skill.cost) + " SRP"
