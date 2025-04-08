extends Control
class_name ActMenuController

# Approaches:
# 1. You can animate each ui component separately
#		- requires N animation players 1 per UI component to animate
#		- requires a bit more code to manage animations that are grouped
#		- requires you to sync timing between animations that will depend on finishing when hiding
# 2. You can animate each ui component together
#		- easier to manage grouped animations; however its reusability in different scenarios is limited
@onready var active_party_member_animation_player: AnimationPlayer = $ActivePartyMemberAnimationPlayer
@onready var sub_menu_animation_player: AnimationPlayer = $SubMenuAnimationPlayer

# controls what animations get played when pressing buttons on the ActMenu UI
@export var animation_type: String = "horizontal"

@onready var atk_btn: Button = $ActionMenu/HBoxContainer/Control5/AtkBtn
@onready var defend_btn: Button = $ActionMenu/HBoxContainer/Control6/DefendBtn
@onready var skill_btn: Button = $ActionMenu/HBoxContainer/Control7/SkillBtn
@onready var flee_btn: Button = $ActionMenu/HBoxContainer/Control8/FleeBtn

@onready var back_btn_target: Button = $TargetMenu/BackBtnTarget
@onready var back_btn_skill: Button = $SkillMenu/BackBtnSkill

@onready var skill_name_btn: Button = $SkillMenu/ScrollContainer/VBoxContainer/SkillRow/SkillName

# Inspired from Browser Back Button -- use a stack to keep track of most recent
# submenu ui element. Topmost ones are ones in current view. Lowermost ones were in view in the past.
@export var sub_menu_ui_history: Array[Control] = []

# UI Elements to be in Stack History
@onready var action_menu: Control = $ActionMenu
@onready var target_menu: NinePatchRect = $TargetMenu
@onready var skill_menu: NinePatchRect = $SkillMenu

# animation libraries
const TARGET_MENU_UI_ANIMATIONS = "target_menu"
const ACTION_MENU_UI_ANIMATIONS = "action_menu"
const SKILL_MENU_UI_ANIMATIONS = "skill_menu"
const ACTIVE_PARTY_MEMBER_UI_ANIMATIONS = "party_member_card"
const HORIZONTAL = "horizontal"
const VERTICAL = "vertical"
const SCALE = "scale"

var ANIM_LIBRARIES: Dictionary = {
	TARGET_MENU_UI_ANIMATIONS: {},
	ACTION_MENU_UI_ANIMATIONS: {},
	SKILL_MENU_UI_ANIMATIONS: {},
	ACTIVE_PARTY_MEMBER_UI_ANIMATIONS: {},
}

# build list of strings that contain the path to each animation to play
func build_anim_libraries():
	var anim_kinds: PackedStringArray = [HORIZONTAL, VERTICAL, SCALE]
	for library in ANIM_LIBRARIES:
		for anim_kind in anim_kinds:
			ANIM_LIBRARIES[library][anim_kind] = "%s/%s" % [library, anim_kind]

func _ready():
	build_anim_libraries()
	
	atk_btn.pressed.connect(func(): on_transition(target_menu))
	skill_btn.pressed.connect(func(): on_transition(skill_menu))
	
	# example to press the first skill on list
	skill_name_btn.pressed.connect(on_skill_pressed)
	
	back_btn_target.pressed.connect(go_back)
	back_btn_skill.pressed.connect(go_back)
	
	# history starts with action menu first
	sub_menu_ui_history.append(action_menu)

func play_intro(anim_type: String):
	if anim_type == "reset":
		active_party_member_animation_player.play("RESET")
		sub_menu_animation_player.play("RESET")
	else:
		play_animation(active_party_member_animation_player, ACTIVE_PARTY_MEMBER_UI_ANIMATIONS, anim_type)
		play_animation(sub_menu_animation_player, ACTION_MENU_UI_ANIMATIONS, anim_type)

func on_animation_switched(anim_type: String):
	animation_type = anim_type

func on_transition(ui_element: Control):
	var ui_element_to_hide: Control = sub_menu_ui_history.back()
	ui_element_to_hide.visible = false
	sub_menu_ui_history.append(ui_element)
	
	ui_element.visible = true
	var anim_library: String = ui_element.name.to_snake_case()
	play_animation(sub_menu_animation_player, anim_library, animation_type)

func play_animation(player: AnimationPlayer, anim_library: String, anim_kind: String, is_backwards: bool = false):
	# no animation
	if animation_type == "no_animation":
		return
	
	var animation_path: String = ANIM_LIBRARIES[anim_library][anim_kind]
	print("playing: ", animation_path)
	if is_backwards:
		player.play_backwards(animation_path)
	else:
		player.play(animation_path)

# in gdscript, in order to disconnect a function from a signal, it needs to be defined
# in the class level and not the function level
var on_nav_away: Callable
func go_back():
	# don't remove last UI element as this should be the default to show
	assert(len(sub_menu_ui_history) > 1)
	
	var ui_element_to_hide: Control = sub_menu_ui_history.back()
	var anim_library: String = ui_element_to_hide.name.to_snake_case()
	play_animation(sub_menu_animation_player, anim_library, animation_type, true)
	
	if animation_type == "no_animation":
		# remove node navigating away from
		ui_element_to_hide.visible = false
		sub_menu_ui_history.pop_back()
		
		# restore node that was previously visible
		var curr_ui_element: Control = sub_menu_ui_history.back()
		curr_ui_element.visible = true
		return
	
	# async by nature since hiding the current sub_menu_ui depends on when the animations finish
	self.on_nav_away = func(anim_name: String):
		on_transition_away(ui_element_to_hide)
		sub_menu_animation_player.animation_finished.disconnect(self.on_nav_away)
	
	sub_menu_animation_player.animation_finished.connect(on_nav_away)

func on_transition_away(ui_element_to_hide: Control):
	# remove node navigating away from
	ui_element_to_hide.visible = false
	sub_menu_ui_history.pop_back()
	
	# removes occasional flickering of new UI element appearing on screen
	# the issue is that it seems like the engine will eagerly render the new
	# ui element on screen as soon as its visibility is set to true
	await RenderingServer.frame_post_draw
	
	# restore node that was previously visible
	var curr_ui_element: Control = sub_menu_ui_history.back()
	curr_ui_element.visible = true
	var anim_library: String = curr_ui_element.name.to_snake_case()
	play_animation(sub_menu_animation_player, anim_library, animation_type)

func on_skill_pressed():
	on_transition(target_menu)
