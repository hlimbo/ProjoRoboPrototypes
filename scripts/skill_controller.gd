extends Node
class_name SkillController

@onready var v_box_container: VBoxContainer = $ScrollContainer/VBoxContainer
@export var skills: Array[Skill] = []

const skill_container_path: String = "res://nodes/skill_container.tscn"
const skill_container_view: Resource = preload(skill_container_path)

func _ready() -> void:
	for i in range(len(skills)):
		print("skill name?? %s" % skills[i].name)
	
	for skill in skills:
		var skill_view: SkillView = skill_container_view.instantiate()
		# ensure all node children for the skill view are ready to be accessed
		skill_view.call_deferred("init", skill)
		v_box_container.add_child(skill_view)
		skill_view.owner = owner
