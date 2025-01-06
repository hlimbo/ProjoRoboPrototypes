extends CanvasLayer

@onready var active_skill_menu: Control = $ActiveSkillMenu
@onready var action_layout: Control = $ActionLayout
@onready var description_panel: Panel = $DescriptionPanel

@onready var attack: Button = $ActionLayout/ActionLayout/Attack
@onready var defend: Button = $ActionLayout/ActionLayout/Defend
@onready var skill: Button = $ActionLayout/ActionLayout/Skills
@onready var flee: Button = $ActionLayout/ActionLayout/Flee
@onready var cancel: Button = $ActiveSkillMenu/Cancel
@onready var party_member_name: Label = $ActionLayout/PartyMemberName

@onready var description_timer: Timer = $DescriptionPanel/Timer
@onready var label: Label = $DescriptionPanel/Label
@onready var active_placeholder_skill: Button = $ActiveSkillMenu/ScrollContainer/VBoxContainer/SkillContainer/ButtonContainer/Button

# Target Menu
@onready var target_menu: PanelContainer = $TargetMenu
@onready var target_label: Label = $TargetMenu/VBoxContainer/TargetLabel
@onready var target_cancel: Button = $TargetMenu/VBoxContainer/Cancel


# Placeholders -- bad code as this pathing is dependent on battle_manager.gd on spawning these mobs in the scene
@onready var mob1: Area2D = $"../blue_mob/Area2D"
@onready var mob2: Area2D = $"../green_mob/Area2D"
@onready var mob3: Area2D = $"../red_mob/Area2D"

const ON_TARGET_HOVERED: String = "on_target_hovered"
const ON_TARGET_UNHOVERED: String = "on_target_unhovered"
const ON_TARGET_CLICKED: String = "on_target_clicked"

## 1-D Graph variables
@onready var one_d_graph: Control = $OneDGraph
@onready var avatar_nodes: Array[Node] = one_d_graph.get_node("PartyPath2D").get_children()
var party_members: Array[Avatar] = []
@onready var enemy_nodes: Array[Node] = one_d_graph.get_node("EnemyPath2D").get_children()
var enemy_avatars: Array[Avatar] = []

const ORDER_STEP: float = 0.858
var did_avatar_skill_start: bool = false
# avatar reference that will make a move
var active_avatar: Avatar = null

@onready var skill_timer: Timer = $SkillTimer
var defense_timers: Array[Timer] = []

var did_tween_start: bool = false

enum Party_Battle_States {
	IN_PROGRESS,
	FLEE,
	WIN,
	DEFEAT,
}

var party_battle_state: Party_Battle_States = Party_Battle_States.IN_PROGRESS

@onready var transition_rect: ColorRect = $TransitionRect
@onready var transition_label: Label = $TransitionRect/Label

func _ready():
	print("ui controller ready called")
	# need to know which avatar is executing the move
	attack.pressed.connect(_on_attack_button_pressed)
	defend.pressed.connect(_on_defend_button_pressed)
	skill.pressed.connect(_on_skills_button_pressed)
	flee.pressed.connect(_on_flee_button_pressed)
	
	# example of reusing code
	cancel.pressed.connect(_on_cancel_button_pressed)
	target_cancel.pressed.connect(_on_cancel_button_pressed)
	
	active_placeholder_skill.pressed.connect(_on_skill_activated)

	mob1.connect(ON_TARGET_HOVERED, on_target_hovered)
	mob2.connect(ON_TARGET_HOVERED, on_target_hovered)
	mob3.connect(ON_TARGET_HOVERED, on_target_hovered)
	
	mob1.connect(ON_TARGET_UNHOVERED, on_target_unhovered)
	mob2.connect(ON_TARGET_UNHOVERED, on_target_unhovered)
	mob3.connect(ON_TARGET_UNHOVERED, on_target_unhovered)
	
	mob1.connect(ON_TARGET_CLICKED, on_target_clicked)
	mob2.connect(ON_TARGET_CLICKED, on_target_clicked)
	mob3.connect(ON_TARGET_CLICKED, on_target_clicked)
	
	for node in avatar_nodes:
		party_members.append(node as Avatar)
	
	for node in enemy_nodes:
		enemy_avatars.append(node as Avatar)
	
	# 1-d graph
	for avatar in party_members:
		avatar.on_start_order_step.connect(on_start_order_step)
		avatar.on_start_exe_step.connect(on_start_exe_step)
		
	var enemy_index = 0
	for avatar in enemy_avatars:
		avatar.on_start_order_step.connect(on_start_order_step)
		
		# binds the avatar value to on_defense_timeout function
		# it copies the callable on_defense_end and binds the
		# avatar reference for it to be later executed once the
		# timer timesout
		avatar.defense_timer.timeout.connect(on_defense_timeout.bind(avatar))
		
		# add timer to scene tree to start ticking
		add_child(avatar.defense_timer)
	
func _on_attack_button_pressed():
	action_layout.visible = false
	
	# pick target to attack
	# enable as pickable which accepts mouse pointer events
	mob1.input_pickable = true
	mob2.input_pickable = true
	mob3.input_pickable = true
	
	# switch to attack selection menu
	target_menu.visible = true

func _on_skills_button_pressed():
	active_skill_menu.visible = true
	action_layout.visible = false

func _on_defend_button_pressed():
	# TODOS
	# increase player's defense temporarily for a set time
	# set it back to what it was previously
	if active_avatar:
		active_avatar.progress_ratio = 1
		label.text = "%s is defending!" % active_avatar.name
	
	description_panel.visible = true
	action_layout.visible = false
	description_timer.start()
	resume_avatars_motion()
	
func _on_cancel_button_pressed():
	target_menu.visible = false
	active_skill_menu.visible = false
	action_layout.visible = true
	
	# disable pickables
	mob1.input_pickable = false
	mob2.input_pickable = false
	mob3.input_pickable = false

func _on_description_timer_timeout():
	target_menu.visible = false
	target_label.text = ""
	
	description_panel.visible = false
	label.text = ""
	
	# reset the avatar that made the move back to the beginning of timeline
	if active_avatar:
		active_avatar.progress_ratio = 0
		active_avatar._curr_speed = active_avatar.move_speed
		active_avatar = null

func _on_skill_activated():
	# TODOs
	# check if enough SRP to cast skill
	# possibly move to SkillContainer and create a skill container script
	active_skill_menu.visible = false
	did_avatar_skill_start = true
	
	skill_timer.start()
	

func _physics_process(delta: float) -> void:
	if did_avatar_skill_start:
		# delay skill until avatar progress ratio reaches 1
		var diff: float = 1 - ORDER_STEP
		var d: float = diff / skill_timer.wait_time
		if active_avatar:
			active_avatar.progress_ratio += d * delta

func _process(delta: float) -> void:
	# check Party Battle Status
	var pending_battle_state: Party_Battle_States = Party_Battle_States.DEFEAT
	for avatar in party_members:
		if avatar.curr_stats.hp > 0:
			pending_battle_state = Party_Battle_States.IN_PROGRESS
			break
			
	# all enemies are defeated
	if len(enemy_avatars) == 0:
		pending_battle_state = Party_Battle_States.WIN
	
	# hacky - setting the flee state happens in another callable function
	# need to either handle state changes in callable functions or have it all happen in process
	if party_battle_state != Party_Battle_States.FLEE:
		party_battle_state = pending_battle_state
	
	if did_tween_start == false and party_battle_state != Party_Battle_States.IN_PROGRESS:
		transition_to_main_scene(party_battle_state)
		did_tween_start = true


func _on_skill_timer_timeout() -> void:
	# TODO may need to hold which avatar skill started in an array
	did_avatar_skill_start = false
	description_panel.visible = true
	
	if active_avatar:
		var enemy_name := "Villainous Gelatin"
		var skill_name := active_placeholder_skill.text
		var dmg := randi_range(32, 64)
		label.text = "%s casts %s to %s. It deals %d damage!" % [active_avatar.name, skill_name, enemy_name, dmg]
	
	description_timer.start()
	resume_avatars_motion()

func _on_flee_button_pressed():
	# TODOs
	# - change scene to the overworld scene when successfully fled from battle
	# - figure out a formula that takes difference between your party's avg level
	# and enemies avg level into consideration for when a flee will be successful
	# - if dice roll is less than flee rate, flee is successful, otherwise flee fails
	var flee_rate := 0.5
	var roll = randf()
	description_panel.visible = true
	action_layout.visible = false
	if roll < flee_rate:
		label.text = "Party fled!"
		party_battle_state = Party_Battle_States.FLEE
	else:
		label.text = "Party cannot escape!"
	
	if active_avatar:
		active_avatar.progress_ratio = 1
	description_timer.start()
	

func on_target_hovered(mob_name: String):
	target_label.text = mob_name

func on_target_unhovered():
	target_label.text = ""

func on_target_clicked(mob_name: String):
	# disable pickables
	mob1.input_pickable = false
	mob2.input_pickable = false
	mob3.input_pickable = false
	
	# basic attack - move avatar immediately towards end of exe
	if active_avatar:
		active_avatar.progress_ratio = 1
		var dmg := randi_range(1, 20)
		label.text = "%s attacked for %d damage to %s" % [active_avatar.name, dmg, mob_name]
	
	target_menu.visible = false
	description_panel.visible = true
	# start timer to hide description panel
	description_timer.start()
	
	resume_avatars_motion()


func pause_avatars_motion():
	var live_party_members = party_members.filter(func(a: Avatar): return a.is_alive)
	var live_enemies = enemy_avatars.filter(func(a: Avatar): return a.is_alive)
	
	for member in live_party_members:
		member._curr_speed = 0
	for enemy in live_enemies:
		enemy._curr_speed = 0

func resume_avatars_motion():
	var live_party_members = party_members.filter(func(a: Avatar): return a.is_alive)
	var live_enemies = enemy_avatars.filter(func(a: Avatar): return a.is_alive)
	
	for member in live_party_members:
		member._curr_speed = member.move_speed
	for enemy in live_enemies:
		enemy._curr_speed = enemy.move_speed

func on_start_order_step(avatar: Avatar) -> void:
	print("entering order step: " + avatar.name)
	avatar._curr_speed = 0
	active_avatar = avatar
	avatar.progress_ratio = ORDER_STEP
	
	pause_avatars_motion()
	
	# entry point for party member to pick a move
	if avatar.avatar_type == Avatar.Avatar_Type.PARTY_MEMBER:
		party_member_name.text = avatar.name
		action_layout.visible = true
	# entry point for enemies to pick a move
	elif avatar.avatar_type == Avatar.Avatar_Type.ENEMY:
		ai_flee(avatar)
	

func on_start_exe_step(body: Node) -> void:
	print("entering exe step")
	# where an action can get emitted depending on which one the player picked
	# for enemies, this is their entry point to do their action

func transition_to_main_scene(status: Party_Battle_States):
	var exit_scene = func():
		var exit_timer = Timer.new()
		exit_timer.autostart = true
		exit_timer.one_shot = true
		exit_timer.wait_time = 3 # seconds
		add_child(exit_timer)
		exit_timer.timeout.connect(func():
			var err = get_tree().change_scene_to_file("res://scenes/main.tscn")
			if err != OK:
				print_rich("[color=red]changing scene failed. Error code: %d [/color]" % err)
		)

	
	match status:
		Party_Battle_States.FLEE:
			transition_label.text = "Party Fled"
		Party_Battle_States.WIN:
			transition_label.text = "Party Won"
		Party_Battle_States.DEFEAT:
			transition_label.text = "Game Over"
	
	
	transition_rect.visible = true
	# need to set z-level to a higher value to hide the PartyPath2D avatar nodes
	transition_rect.z_index = 1
	var tween: Tween = get_tree().create_tween()
	# set tween alpha from 0 alpha to 1 alpha on the modulate property's alpha component
	tween.parallel().tween_property(transition_rect, "modulate:a", 1, 1).from(0)
	tween.parallel().tween_property(transition_rect,"self_modulate:a", 1, 1).from(0)
	tween.finished.connect(exit_scene)


#region AI Commands
func ai_determine_move(avatar: Avatar) -> void:
	var possible_actions: Array[Callable] = [ai_attack, ai_defend, ai_use_random_skill]
	var random_move_index = randi_range(0, len(possible_actions) - 1)
	possible_actions[random_move_index].call(avatar)

func ai_attack(avatar: Avatar) -> void:
		avatar.progress_ratio = 1
		# pick a random party member
		var live_party_members: Array[Avatar] = party_members.filter(func(p: Avatar): return p.is_alive)
		
		# no more party members to attack
		if len(live_party_members) == 0:
			return
		
		var i = randi_range(0, len(live_party_members) - 1)
		var target: Avatar = live_party_members[i]
		# compute random dmg to deal - TODO: add damage calculator
		var dmg = randi_range(1,20)
		target.curr_stats.hp -= dmg
		# target downed...
		if target.curr_stats.hp <= 0:
			target.curr_stats.hp = 0
			# reset their timeline back to 0
			target.progress_ratio = 0
			target._curr_speed = 0
			target.is_alive = false
			
		
		# display damage dealt to target
		description_panel.visible = true
		label.text = "%s dealt %d damage to %s" % [avatar.name, dmg, target.name]
		description_timer.start()

func ai_defend(avatar: Avatar) -> void:
	# TODO - determine a formula for defending against an attack
	avatar.curr_stats.defense += avatar.curr_stats.defense * .25
	avatar.progress_ratio = 1
	description_panel.visible = true
	label.text = "%s is defending" % [avatar.name]
	avatar.defense_timer.start()

func ai_flee(avatar: Avatar) -> void:
	description_panel.visible = true
	label.text = "%s fled from battle" % avatar.name
	description_timer.start()
	
	var i = 0
	while i < len(enemy_avatars):
		if enemy_avatars[i] == avatar:
			break
		i += 1
		
	# remove avatar from scene if found
	if i < len(enemy_avatars):
		# invalidate active_avatar as it will be removed
		active_avatar = null
		enemy_avatars.remove_at(i)
		remove_child(avatar)
		avatar.queue_free()
		
	resume_avatars_motion()

func ai_use_random_skill(avatar: Avatar) -> void:
	pass

func on_defense_timeout(avatar: Avatar) -> void:
	print("avatar defense ending: %s" % avatar.name)
	resume_avatars_motion()
	description_timer.start()

#endregion
