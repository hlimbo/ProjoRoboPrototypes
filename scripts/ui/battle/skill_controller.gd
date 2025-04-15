extends Node
class_name SkillController

# dependencies
var current_actor: Actor

@onready var v_box_container: VBoxContainer = $ScrollContainer/MarginContainer/VBoxContainer
@onready var ui_layout: UIController = $".."

# key - party_member name -> String
# value - Array[SkillView]
@export var party_member_skills: Dictionary = {}

const skill_container_view: Resource = preload("res://nodes/ui/battle/skill_view.tscn")


func lazy_load_skills(party_member: Actor):
	# if party member same as current_actor, do nothing
	if current_actor == party_member:
		return
	
	# hide previous actor's skills
	if is_instance_valid(current_actor):
		hide_skill_views(current_actor)
	
	current_actor = party_member
	assert(is_instance_valid(current_actor))
	assert(is_instance_valid(current_actor.avatar))
	assert(is_instance_valid(current_actor.avatar.avatar_data))
	assert(is_instance_valid(current_actor.skill_system_component))
	
	var avatar_name: String = current_actor.avatar.avatar_data.avatar_name
	if avatar_name in party_member_skills:
		reveal_skill_views(current_actor)
	else:
		create_skill_views(current_actor)
	

func toggle_skill_views_visibility(actor: Actor, is_visible: bool):
	var avatar_name: String = actor.avatar.avatar_data.avatar_name
	if avatar_name in party_member_skills:
		for skill_view in party_member_skills[avatar_name]:
			(skill_view as SkillView).visible = is_visible

func hide_skill_views(actor: Actor):
	toggle_skill_views_visibility(actor, false)
	
func reveal_skill_views(actor: Actor):
	toggle_skill_views_visibility(actor, true)
	
func create_skill_views(actor: Actor):
	var avatar_name: String = actor.avatar.avatar_data.avatar_name
	party_member_skills[avatar_name] = []
	for skill in actor.skill_system_component.skills.values():
		var skill_view: SkillView = skill_container_view.instantiate()
		v_box_container.add_child(skill_view)
		skill_view.init(skill)
		skill_view.connect_button(on_skill_button_pressed)
		party_member_skills[avatar_name].append(skill_view)

# TODO: pass in ui_layout as a dependency for this function to call its function later on
# to set the pending skill that a party member will use
func on_skill_button_pressed(skill: Skill):
	print("skill pressed is: %s" % skill.name)
	if current_actor and current_actor.avatar:
		print("avatar %s is beginning to use %s" % [current_actor.avatar.avatar_data.avatar_name, skill.name])

		# transition to target selection next
		ui_layout.action_layout.visible = false
		ui_layout.active_skill_menu.visible = false
		ui_layout.toggle_pickable_mobs(true)
		# switch to attack selection menu
		ui_layout.target_menu.visible = true
		ui_layout.pending_skill = skill
