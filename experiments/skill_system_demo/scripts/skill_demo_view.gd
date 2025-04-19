extends Control
class_name SkillDemoView

@onready var skill_name: Label = $SkillName
@onready var skill_cost: Label = $SkillCost
@onready var cast_button: Button = $CastButton

signal on_cast_pressed

func set_fields(_skill_name: String, _skill_cost: int):
	skill_name.set_deferred("text",_skill_name)
	skill_cost.set_deferred("text","%d" % _skill_cost)

func _ready():
	cast_button.pressed.connect(_on_cast_pressed)
	
func _on_cast_pressed():
	on_cast_pressed.emit()
