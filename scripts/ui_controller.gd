extends CanvasLayer
class_name UIController

### Dependencies ###
# owner is the root node of the scene that this node belongs to e.g. main
@onready var battle_manager: BattleManager = owner.get_node("BattleManager")
@export var battle_spawn_manager: BattleSpawnManager
@export var battle_timer_manager: BattleTimerManager

@onready var active_skill_menu: Control = $ActiveSkillMenu
@onready var action_layout: Control = $ActionLayout
@onready var description_panel: Panel = $DescriptionPanel

@onready var attack: Button = $ActionLayout/ActionLayout/Attack
@onready var defend: Button = $ActionLayout/ActionLayout/Defend
@onready var skill_btn: Button = $ActionLayout/ActionLayout/Skills
@onready var flee: Button = $ActionLayout/ActionLayout/Flee
@onready var cancel: Button = $ActiveSkillMenu/Cancel
@onready var party_member_name: Label = $ActionLayout/PartyMemberName

@onready var description_timer: Timer = $DescriptionPanel/Timer
@onready var label: Label = $DescriptionPanel/Label
# @onready var active_placeholder_skill: Button = $ActiveSkillMenu/ScrollContainer/VBoxContainer/SkillContainer/ButtonContainer/Button
@onready var skill_controller: SkillController = $ActiveSkillMenu
@onready var skill_containers: Array[Node] = $ActiveSkillMenu/ScrollContainer/MarginContainer/VBoxContainer.get_children()
var skills: Array[SkillView] = []

# TODO: need to reorganize nodes to make things cleaner and easier to understand
@onready var camera_2d: Camera2D = $"../BattleScene/Camera2D"
var original_cam_pos: Vector2

# Target Menu
@onready var target_menu: PanelContainer = $TargetMenu
@onready var target_label: Label = $TargetMenu/VBoxContainer/TargetLabel
@onready var target_cancel: Button = $TargetMenu/VBoxContainer/Cancel

### 1-D Graph variables
#@onready var one_d_graph: Control = $OneDGraph
#@onready var avatar_nodes: Array[Node] = one_d_graph.get_node("PartyPath2D").get_children()
#var party_members: Array[Avatar] = []
#@onready var enemy_nodes: Array[Node] = one_d_graph.get_node("EnemyPath2D").get_children()
#var enemy_avatars: Array[Avatar] = []

const ORDER_STEP: float = 0.858
var did_tween_start: bool = false

enum Party_Battle_States {
	IN_PROGRESS,
	FLEE,
	WIN,
	DEFEAT,
}

enum Attack_Type {
	BASIC,
	SKILL,
}

var party_battle_state: Party_Battle_States = Party_Battle_States.IN_PROGRESS

@onready var transition_rect: ColorRect = $TransitionRect
@onready var transition_label: Label = $TransitionRect/Label

var battle_controller: BattleController
var action_buttons: BattleController.ActionButtons

#var timers: Array[Timer] = []
var attack_type: Attack_Type
var pending_skill: Skill

func on_end_turn(actor: Actor):
	description_timer.start()
	# GAME FEEL: this feels terrible from a game feel perspective... 
	# other actors should be able to move as long as the following are NOT happening:
	# 1. player picking a move
	# 2. actor is in front of their target about to perform their skill
	# 3. actor begins to cast a skill
	actor.avatar.battle_timers.resume_delay_timer.start()

func on_resume_play():
	resume_actors_motion()

func _ready():
	print("ui controller ready called")
	battle_controller = BattleController.new()
	action_buttons = BattleController.ActionButtons.new()
	action_buttons.init(attack, skill_btn, defend, flee, cancel)
	
	cancel.pressed.connect(_on_cancel_button_pressed)
	target_cancel.pressed.connect(_on_cancel_button_pressed)
		
	for enemy in battle_spawn_manager.get_enemies():
		enemy.get_target_selection_area().on_target_hovered.connect(on_target_hovered)
		enemy.get_target_selection_area().on_target_unhovered.connect(on_target_unhovered)
	
	# 1-d graph
	BattleSignals.on_end_turn.connect(on_end_turn)
	BattleSignals.on_resume_play.connect(on_resume_play)
	BattleSignals.on_start_turn.connect(on_start_order_step)
	
	battle_manager.damage_calculator.on_damage_received.connect(on_show_description_panel_basic_attack)
	battle_manager.damage_calculator.on_damage_received.connect(on_check_damage_receiver_is_defeated)

	var enemy_avatars: Array[Avatar] = battle_spawn_manager.get_enemy_avatars()
	var party_members: Array[Avatar] = battle_spawn_manager.get_party_member_avatars()
	
	
	# for camera motions
	original_cam_pos = camera_2d.position

func toggle_pickable_mobs(input_pickable: bool):
	# pick target to attack
	# enable as pickable which accepts mouse pointer events
	for enemy in battle_spawn_manager.get_enemies():
		enemy.get_target_selection_area().input_pickable = input_pickable

func _on_attack_button_pressed(actor: Actor):
	action_layout.visible = false
	toggle_pickable_mobs(true)
	# switch to attack selection menu
	target_menu.visible = true
	attack_type = Attack_Type.BASIC

func _on_skills_button_pressed(actor: Actor):
	active_skill_menu.visible = true
	action_layout.visible = false
	
	# set the correct avatar that will be executing their own skills
	skill_controller.avatar = actor.avatar
	attack_type = Attack_Type.SKILL

func start_defend(actor: Actor):
	var avatar: Avatar = actor.avatar
	label.text = "%s is defending!" % avatar.name
	
	description_panel.visible = true
	action_layout.visible = false
	
	var def_cmd = DefendCommand.new()
	def_cmd.execute(actor)
	
	description_timer.start()
	
	var actors: Array[Actor] = battle_spawn_manager.get_all_actors()	
	battle_timer_manager.resume_actors_excluding(actors, actor)

func _on_defend_button_pressed(actor: Actor):
	start_defend(actor)
	
func _on_cancel_button_pressed():
	target_menu.visible = false
	active_skill_menu.visible = false
	action_layout.visible = true
	
	toggle_pickable_mobs(false)

func _on_description_timer_timeout():
	target_menu.visible = false
	target_label.text = ""
	
	description_panel.visible = false
	label.text = ""

func _process(_delta: float) -> void:
	# check if enemies are defeated
	var enemies: Array[Actor] = battle_spawn_manager.get_enemies()
	var removed_enemies: Array[Actor] = []
	for i in range(len(enemies)):
		if enemies[i] and !enemies[i].avatar.is_alive:
			removed_enemies.append(enemies[i])
	
	while len(removed_enemies) > 0:
		var enemy: Actor = removed_enemies.pop_back()
		# slow algorithm but ok since there will be between 1 to 6 enemies in a battle
		battle_spawn_manager.remove_actor(Constants.Avatar_Type.ENEMY, enemy)
		enemy.queue_free()
	
	# check Party Battle Status
	var party_members: Array[Actor] = battle_spawn_manager.get_party_members()
	var pending_battle_state: Party_Battle_States = Party_Battle_States.DEFEAT
	for actor in party_members:
		if actor.avatar.is_alive:
			pending_battle_state = Party_Battle_States.IN_PROGRESS
			break
			
	## all enemies are defeated
	if len(enemies) == 0:
		pending_battle_state = Party_Battle_States.WIN
	#
	# hacky - setting the flee state happens in another callable function
	# need to either handle state changes in callable functions or have it all happen in process
	if party_battle_state != Party_Battle_States.FLEE:
		party_battle_state = pending_battle_state
	
	if did_tween_start == false and party_battle_state != Party_Battle_States.IN_PROGRESS:
		transition_to_main_scene(party_battle_state)
		did_tween_start = true

func on_determine_flee_rate(actor: Actor):
	# TODOs
	# - change scene to the overworld scene when successfully fled from battle
	# - figure out a formula that takes difference between your party's avg level
	# and enemies avg level into consideration for when a flee will be successful
	# - if dice roll is less than flee rate, flee is successful, otherwise flee fails
	# - modify it to where once timeline reaches progress = 1, decide if party can flee or not
	
	# pause timers and avatar movement along timeline
	pause_actors_motion()
	
	var flee_rate := 0.5
	var roll = randf()
	description_panel.visible = true
	if roll < flee_rate:
		label.text = "Party fled!"
		party_battle_state = Party_Battle_States.FLEE
		
		# trigger flee command for all party members
		var party_members: Array[Actor] = battle_spawn_manager.get_party_members()
		for party_member in party_members:
			var flee_cmd = FleeCommand.new()
			flee_cmd.execute(party_member)
	else:
		label.text = "Party cannot escape!"
		
	description_timer.start()
	BattleSignals.on_end_turn.emit(actor)

func _on_flee_button_pressed(actor: Actor):
	# set flee execution speed
	var avatar: Avatar = actor.avatar
	avatar.battle_state = Constants.Battle_State.PENDING_MOVE
	avatar.update_battle_state_text()
	
	# delay skill until avatar progress ratio reaches 1
	var wait_time: float = avatar.battle_timers.flee_timer.wait_time
	avatar._curr_speed = avatar.calculate_action_execution_speed(wait_time)
	avatar.resume_motion = true
	
	resume_actors_motion()
	
	action_layout.visible = false
	avatar.battle_timers.flee_timer.start()


func on_target_hovered(actor: Actor, mob: MobSelection):
	target_label.text = actor.avatar.name
	
	print("mob position: %s" % str(mob.root_node.position))
	print("cam position: %s" % str(camera_2d.position))
	
	camera_2d.position = mob.root_node.position

func on_target_unhovered():
	target_label.text = ""
	camera_2d.position = original_cam_pos


func on_target_clicked(dr_actor: Actor, dd_actor: Actor):
	toggle_pickable_mobs(false)
	
	var damage_receiver: Avatar = dr_actor.avatar
	var damage_dealer: Avatar = dd_actor.avatar
	
	if attack_type == Attack_Type.BASIC:
		var atk_cmd = AttackCommand.new()
		atk_cmd.target = dr_actor
		atk_cmd.execute(dd_actor)
		
		target_menu.visible = false
		
	elif attack_type == Attack_Type.SKILL:
		var on_timeout = func(): on_party_member_skill_end(dr_actor, dd_actor)
		damage_dealer.battle_timers.skill_timer.timeout.connect(on_timeout, ConnectFlags.CONNECT_ONE_SHOT)
		
		var begin_skill_cmd = BeginSkillCommand.new()
		begin_skill_cmd.execute(dd_actor)
		
		target_menu.visible = false
		active_skill_menu.visible = false

	resume_actors_motion()

func pause_actors_motion():
	var party_members: Array[Actor] = battle_spawn_manager.get_party_members()
	var enemies: Array[Actor] = battle_spawn_manager.get_enemies()
	
	var live_party_members = party_members.filter(func(a: Actor): return a.avatar.is_alive)
	var live_enemies = enemies.filter(func(a: Actor): return a.avatar.is_alive)
	
	description_timer.paused = true
	battle_timer_manager.pause_actors(live_party_members)
	battle_timer_manager.pause_actors(live_enemies)
	

func resume_actors_motion():
	var party_members: Array[Actor] = battle_spawn_manager.get_party_members()
	var enemies: Array[Actor] = battle_spawn_manager.get_enemies()
	
	var live_party_members = party_members.filter(func(a: Actor): return a.avatar.is_alive)
	var live_enemies = enemies.filter(func(a: Actor): return a.avatar.is_alive)
	
	#var is_exe_move = func(a: Avatar): 
		#return a.battle_state == Constants.Battle_State.EXECUTING_MOVE
	
	# may cause stalls as there other timers ticking....
	# don't resume avatar motion if any live party member is making a move or a move is executing
	var any_party_member_making_move: bool = live_party_members.any(func(a: Actor): return a.avatar.battle_state == Constants.Battle_State.MOVE_SELECTION)
	#var any_executing_move: bool = live_party_members.any(is_exe_move) or live_enemies.any(is_exe_move) 
	
	if any_party_member_making_move:
		return
	
	description_timer.paused = false
	battle_timer_manager.resume_actors(live_party_members)
	battle_timer_manager.resume_actors(live_enemies)

func on_start_order_step(actor: Actor) -> void:
	var avatar: Avatar = actor.avatar
	print("entering order step %s at time: %d" % [avatar.name, Time.get_ticks_msec()])
	avatar.progress_ratio = ORDER_STEP
	
	# entry point for party member to pick a move
	if avatar.avatar_type == Avatar.Avatar_Type.PARTY_MEMBER:
		# pause all timers to prevent them going off when party member is picking a move
		pause_actors_motion()
		party_member_name.text = avatar.name
		action_layout.visible = true
		
		# Disconnect previous action connections 
		# avoids previous party member actions from being triggered
		Utility.disconnect_all_signal_connections(action_buttons.attack_button.pressed)
		Utility.disconnect_all_signal_connections(action_buttons.defend_button.pressed)
		Utility.disconnect_all_signal_connections(action_buttons.pick_skills_button.pressed)
		Utility.disconnect_all_signal_connections(action_buttons.flee_button.pressed)
		Utility.disconnect_all_signal_connections(avatar.battle_timers.flee_timer.timeout)

		for enemy in battle_spawn_manager.get_enemies():
			# Disconnect mob target selection and previous actor relationship
			var target_selection_area: MobSelection = enemy.get_target_selection_area()
			Utility.disconnect_all_signal_connections(target_selection_area.on_target_clicked)
			# Connect all possible enemy targets that can be clicked on when doing target selection
			var lambda = func(e: Actor, party_member: Actor): on_target_clicked(e, party_member)
			target_selection_area.on_target_clicked.connect(lambda.bind(enemy, actor))
		
		action_buttons.attack_button.pressed.connect(_on_attack_button_pressed.bind(actor))
		action_buttons.defend_button.pressed.connect(_on_defend_button_pressed.bind(actor))
		action_buttons.pick_skills_button.pressed.connect(_on_skills_button_pressed.bind(actor))
		action_buttons.flee_button.pressed.connect(_on_flee_button_pressed.bind(actor))
		avatar.battle_timers.flee_timer.timeout.connect(on_determine_flee_rate.bind(actor))
		
	# entry point for enemies to pick a move
	elif avatar.avatar_type == Constants.Avatar_Type.ENEMY:
		#ai_determine_move(actor)
		#ai_use_random_skill(actor)
		start_defend(actor)
		#ai_flee(actor)
		#ai_attack(actor)

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
func ai_determine_move(actor: Actor) -> void:
	var possible_actions: Array[Callable] = [ai_attack, start_defend, ai_use_random_skill]
	var random_move_index = randi_range(0, len(possible_actions) - 1)
	possible_actions[random_move_index].call(actor)

func ai_attack(actor: Actor) -> void:
	# pick a random party member
	var party_members: Array[Actor] = battle_spawn_manager.get_party_members()
	var live_party_members: Array[Actor] = party_members.filter(func(p: Actor): return p.avatar.is_alive)
	
	if len(live_party_members) == 0:
		print_rich("[color=yellow]Warning no more party members to attack[/color]")
		return
	
	var atk_cmd = AttackCommand.new()
	# pick random target to attack
	var i = randi_range(0, len(live_party_members) - 1)
	var target: Actor = live_party_members[i]
	atk_cmd.target = target
	atk_cmd.execute(actor)
	
func ai_flee(actor: Actor) -> void:
	print("ai_flee will be reworked once player commands are integrated")
	var avatar: Avatar = actor.avatar
	description_panel.visible = true
	label.text = "%s fled from battle" % avatar.name
	description_timer.start()
	
	var flee_cmd = FleeCommand.new()
	flee_cmd.execute(actor)

func ai_use_random_skill(actor: Actor) -> void:
	var avatar: Avatar = actor.avatar
	
	var party_members: Array[Actor] = battle_spawn_manager.get_party_members()
	var members: Array[Actor] = party_members.filter(func(p: Actor): return p.avatar.is_alive)
	if len(members) == 0:
		print_rich("[color=yellow]No party members to cast skills on[/color]")
		BattleSignals.on_end_turn.emit(actor)
		return
	
	var damage_receiver: Actor = members[randi_range(0, len(members) - 1)]
	avatar.battle_timers.skill_timer.timeout.connect(on_ai_skill_end.bind(damage_receiver, actor), ConnectFlags.CONNECT_ONE_SHOT)
	
	var begin_skill_cmd = BeginSkillCommand.new()
	begin_skill_cmd.execute(actor)

func on_ai_skill_end(damage_receiver: Actor, damage_dealer: Actor) -> void:
	var avatar: Avatar = damage_dealer.avatar
	var target: Avatar = damage_receiver.avatar
	
	pause_actors_motion()
	
	print("avatar %s skill end at time %d" % [avatar.name, Time.get_ticks_msec()])
	# pick random skill
	var skill1 = Skill.new(1, 5, "Sizzle")
	var skill2 = Skill.new(4, 10, "Spitfire")
	var skill3 = Skill.new(8, 20, "Oven Overload")
	
	# TODO: check ahead of time if enemy can cast a skill, if not, don't do this action
	var skills: Array[Skill] = [skill1, skill2, skill3]
	var castable_skills: Array[Skill] = skills.filter(func(s: Skill): return s.cost <= avatar.curr_stats.skill_points)

	description_panel.visible = true
	if len(castable_skills) == 0:
		label.text = "%s cannot execute any skills!" % avatar.name
		return
	
	var skill_index: int = randi_range(0, len(castable_skills) - 1)
	var skill: Skill = skills[skill_index]
	
	# TODO: add motion to skill being utilized and move damage calculations to actor logic
	var skill_cmd = SkillPlaceholderCommand.new()
	skill_cmd.target = damage_receiver
	skill_cmd.skill = skill
	skill_cmd.execute(damage_dealer)
	
	var dmg: int = battle_manager.damage_calculator.calculate_damage(damage_receiver, damage_dealer)
	target.curr_stats.hp = maxi(target.curr_stats.hp - dmg, 0)

	battle_manager.damage_calculator.on_damage_received.emit(damage_receiver, damage_dealer, dmg)
	on_skill_attack_damage_received(damage_receiver, damage_dealer, dmg)
	
	var text = "%s used %s on %s! It dealt %d damage" % [avatar.curr_stats.name, skill.name, target.curr_stats.name, dmg]
	label.text = text 

#endregion

func on_party_member_skill_end(dr_actor: Actor, dd_actor: Actor):
	var damage_receiver: Avatar = dr_actor.avatar
	var damage_dealer: Avatar = dd_actor.avatar
	
	## TODO pause all avatar and actor movement/timers except for actor performing the skill
	pause_actors_motion()

	var skill: Skill = pending_skill
	# you can have an AOE skill, a single target skill, or a multi-target skill
	var skill_cmd = SkillPlaceholderCommand.new()
	skill_cmd.target = dr_actor
	skill_cmd.skill = skill
	skill_cmd.execute(dd_actor)
		
	print("on party member skill end %s" % damage_dealer.name)
	var enemy_name := damage_receiver.name
	var skill_name := skill.name
	var dmg := skill.attack
		
	damage_receiver.curr_stats.hp = maxi(damage_receiver.curr_stats.hp - dmg, 0)
	battle_manager.damage_calculator.on_damage_received.emit(dr_actor, dd_actor, dmg)
	on_skill_attack_damage_received(dr_actor, dd_actor, dmg)
	label.text = "%s casts %s to %s. It deals %d damage!" % [damage_dealer.name, skill_name, enemy_name, dmg]

func on_show_description_panel_basic_attack(damage_receiver: Actor, damage_dealer: Actor, damage: int):
	target_menu.visible = false
	description_panel.visible = true
	# start to begin hiding the description panel after some time passed
	description_timer.start()
	var dd_avatar: Avatar = damage_dealer.avatar
	var dr_avatar: Avatar = damage_receiver.avatar
	print("on damage received basic attack: %s atks %s for %d dmg" % [dd_avatar.curr_stats.name, dr_avatar.curr_stats.name, damage])
	
	# TODO: need to know what action the actor picked in order to print out the appropriate message for attack or skill
	var text = "%s attacked %s for %d damage" % [dd_avatar.curr_stats.name, dr_avatar.curr_stats.name, damage]
	label.text = text
	
func on_check_damage_receiver_is_defeated(damage_receiver: Actor, damage_dealer: Actor, damage: int):
	var dd_avatar: Avatar = damage_dealer.avatar
	var dr_avatar: Avatar = damage_receiver.avatar
	
	# check if target is downed... no longer able to battle
	if dr_avatar.curr_stats.hp <= 0:
		print("damage receiver %s is defeated!" % dr_avatar.curr_stats.name)
		dr_avatar.is_alive = false
		dr_avatar.curr_stats.hp = 0
		dr_avatar.progress_ratio = 0
		dr_avatar.resume_motion = false
		dr_avatar.is_alive = false

func on_skill_attack_damage_received(damage_receiver: Actor, damage_dealer: Actor, damage: int):
	var dd_avatar: Avatar = damage_dealer.avatar
	var dr_avatar: Avatar = damage_receiver.avatar

	description_panel.visible = true
	description_timer.start()
	dd_avatar.battle_state = Constants.Battle_State.EXECUTING_MOVE
	dd_avatar.update_battle_state_text()
		
	# TODO: remove once skill motions are implemented in actor
	BattleSignals.on_end_turn.emit(damage_dealer)
