extends Node
class_name SkillController

@onready var v_box_container: VBoxContainer = $ScrollContainer/MarginContainer/VBoxContainer
@onready var ui_layout: UIController = $".."

# TODO: each party member will have their own set of skills
@export var skills: Array[Skill] = []

const skill_container_path: String = "res://nodes/skill_container.tscn"
const skill_container_view: Resource = preload(skill_container_path)

var avatar: Avatar

func _ready() -> void:
	for skill in skills:
		var skill_view: SkillView = skill_container_view.instantiate()
		# ensure all node children for the skill view are ready to be accessed
		skill_view.call_deferred("init", skill)
		skill_view.call_deferred("connect_button", on_skill_button_pressed)
		v_box_container.add_child(skill_view)

func on_skill_button_pressed(skill: Skill):
	print("skill pressed is: %s" % skill.name)
	if avatar:
		print("avatar %s is beginning to use %s" % [avatar.name, skill.name])
		
		# transition to target selection next
		ui_layout.action_layout.visible = false
		ui_layout.active_skill_menu.visible = false
		ui_layout.toggle_pickable_mobs(true)
		# switch to attack selection menu
		ui_layout.target_menu.visible = true
		ui_layout.pending_skill = skill
