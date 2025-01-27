extends CanvasLayer
class_name UIController

# owner is the root node of the scene that this node belongs to e.g. main
@onready var battle_manager: BattleManager = owner.get_node("BattleManager")

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

## 1-D Graph variables
@onready var one_d_graph: Control = $OneDGraph
@onready var avatar_nodes: Array[Node] = one_d_graph.get_node("PartyPath2D").get_children()
var party_members: Array[Avatar] = []
@onready var enemy_nodes: Array[Node] = one_d_graph.get_node("EnemyPath2D").get_children()
var enemy_avatars: Array[Avatar] = []

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

var timers: Array[Timer] = []
var attack_type: Attack_Type
var pending_skill: Skill

func on_end_turn(actor: Actor):
	description_timer.start()
	actor.avatar.battle_timers.resume_delay_timer.start()

func on_resume_play(_actor: Actor):
	resume_avatars_motion()
	toggle_timer_tick(false)

func _ready():
	print("ui controller ready called")
	battle_controller = BattleController.new()
	action_buttons = BattleController.ActionButtons.new()
	action_buttons.init(attack, skill_btn, defend, flee, cancel)
	
	cancel.pressed.connect(_on_cancel_button_pressed)
	target_cancel.pressed.connect(_on_cancel_button_pressed)
	
	for node in avatar_nodes:
		party_members.append(node as Avatar)
	
	for node in enemy_nodes:
		enemy_avatars.append(node as Avatar)
		
	for enemy in battle_manager.enemies:
		enemy.get_target_selection_area().on_target_hovered.connect(on_target_hovered)
		enemy.get_target_selection_area().on_target_unhovered.connect(on_target_unhovered)
	
	# 1-d graph
	BattleSignals.on_end_turn.connect(on_end_turn)
	BattleSignals.on_resume_play.connect(on_resume_play)
	BattleSignals.on_start_turn.connect(on_start_order_step)
	
	for avatar in enemy_avatars:
		avatar.battle_timers.skill_timer.timeout.connect(on_ai_skill_end.bind(avatar))
		
	# Fetch all timers in battle scene
	for avatar in enemy_avatars:
		timers.append(avatar.battle_timers.skill_timer)
		timers.append(avatar.battle_timers.defense_timer)
		#timers.append(avatar.battle_timers.resume_delay_timer)
		timers.append(avatar.battle_timers.flee_timer)
	
	for avatar in party_members:
		timers.append(avatar.battle_timers.skill_timer)
		timers.append(avatar.battle_timers.defense_timer)
		#timers.append(avatar.battle_timers.resume_delay_timer)
		timers.append(avatar.battle_timers.flee_timer)
	
	timers.append(description_timer)
	
	# for camera motions
	original_cam_pos = camera_2d.position
	
	battle_manager.damage_calculator.on_damage_received.connect(ui_on_damage_received)

func toggle_timer_tick(paused: bool):
	for timer in timers:
		if timer and not timer.is_queued_for_deletion():
			timer.paused = paused

func toggle_pickable_mobs(input_pickable: bool):
	# pick target to attack
	# enable as pickable which accepts mouse pointer events
	for enemy in battle_manager.enemies:
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

func _on_defend_button_pressed(actor: Actor):
	var avatar: Avatar = actor.avatar
	avatar.progress_ratio = 1
	label.text = "%s is defending!" % avatar.name
	
	description_panel.visible = true
	action_layout.visible = false
	
	avatar.battle_state = avatar.Battle_State.EXECUTING_MOVE
	avatar.update_battle_state_text()
	
	var def_cmd = DefendCommand.new()
	def_cmd.execute(actor)
	
	description_timer.start()
	avatar.battle_timers.defense_timer.start()
	
	resume_avatars_motion()
	toggle_timer_tick(false)
	
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
	pass
	# TODO - add back once command pattern implemented for Actors
	## check if enemies are defeated
	#var i = 0
	#var limit = len(enemy_avatars)
	#while i < limit:
		#if enemy_avatars[i].curr_stats.hp <= 0:
			#enemy_avatars[i].queue_free()
			## TODO - don't do this... find a better solution to remove (prefer to remove rootmost node)
			#mobs[i].get_parent().queue_free()
			#enemy_avatars.remove_at(i)
			#mobs.remove_at(i)
			#
			## shift index to left and update limit as item is removed
			## and maybe skipped...
			#i -= 1
			#limit = len(enemy_avatars)
			#
		#i += 1
	
	# TODO - comment back in once command pattern integrated
	## check Party Battle Status
	#var pending_battle_state: Party_Battle_States = Party_Battle_States.DEFEAT
	#for avatar in party_members:
		#if avatar.curr_stats.hp > 0:
			#pending_battle_state = Party_Battle_States.IN_PROGRESS
			#break
			#
	## all enemies are defeated
	#if len(enemy_avatars) == 0:
		#pending_battle_state = Party_Battle_States.WIN
	#
	## hacky - setting the flee state happens in another callable function
	## need to either handle state changes in callable functions or have it all happen in process
	#if party_battle_state != Party_Battle_States.FLEE:
		#party_battle_state = pending_battle_state
	#
	#if did_tween_start == false and party_battle_state != Party_Battle_States.IN_PROGRESS:
		#transition_to_main_scene(party_battle_state)
		#did_tween_start = true

func on_determine_flee_rate(actor: Actor):
	# TODOs
	# - change scene to the overworld scene when successfully fled from battle
	# - figure out a formula that takes difference between your party's avg level
	# and enemies avg level into consideration for when a flee will be successful
	# - if dice roll is less than flee rate, flee is successful, otherwise flee fails
	# - modify it to where once timeline reaches progress = 1, decide if party can flee or not
	
	# pause timers and avatar movement along timeline
	toggle_timer_tick(true)
	pause_avatars_motion()
	
	var flee_rate := 0.5
	var roll = randf()
	description_panel.visible = true
	if roll < flee_rate:
		label.text = "Party fled!"
		party_battle_state = Party_Battle_States.FLEE
		pause_avatars_motion()
		
		# trigger flee command for all party members
		for party_member in party_members:
			var flee_cmd = FleeCommand.new()
			flee_cmd.execute(party_member.actor.get_ref())
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
	var diff: float = 1 - avatar.progress_ratio
	var flee_exec_time: float = diff / avatar.battle_timers.flee_timer.wait_time
	avatar._curr_speed = flee_exec_time
	avatar.resume_motion = true
	
	toggle_timer_tick(false)
	resume_avatars_motion()
	
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
		# move avatar immediately towards end of exe
		damage_dealer.progress_ratio = 1
		
		var atk_cmd = AttackCommand.new()
		atk_cmd.target = dr_actor
		atk_cmd.execute(dd_actor)
		
	elif attack_type == Attack_Type.SKILL:
		# set skill execution speed
		damage_dealer.battle_state = Constants.Battle_State.PENDING_MOVE
		damage_dealer.update_battle_state_text()
		# delay skill until avatar progress ratio reaches 1
		var diff: float = 1 - damage_dealer.progress_ratio
		var skill_exec_time: float = diff / damage_dealer.battle_timers.skill_timer.wait_time
		damage_dealer._curr_speed = skill_exec_time
		
		damage_dealer.battle_timers.skill_timer.start()
		
		var on_timeout = func(): on_party_member_skill_end(dr_actor, dd_actor)
		damage_dealer.battle_timers.skill_timer.timeout.connect(on_timeout, ConnectFlags.CONNECT_ONE_SHOT)
		
		target_menu.visible = false
		active_skill_menu.visible = false
		BattleSignals.on_end_turn.emit(dd_actor)


func pause_avatars_motion():
	var live_party_members = party_members.filter(func(a: Avatar): return a.is_alive)
	var live_enemies = enemy_avatars.filter(func(a: Avatar): return a.is_alive)
	
	for member in live_party_members:
		member.resume_motion = false
	for enemy in live_enemies:
		enemy.resume_motion = false

func can_resume_avatars_motion() -> bool:
	var live_party_members = party_members.filter(func(a: Avatar): return a.is_alive)
	var live_enemies = enemy_avatars.filter(func(a: Avatar): return a.is_alive)
	# Don't resume avatar motion if any party members are 
	# executing a move or picking a move
	var is_any_party_member_acting: bool = live_party_members.any(
			func(a: Avatar): return a.battle_state == a.Battle_State.EXECUTING_MOVE or a.battle_state == a.Battle_State.MOVE_SELECTION
		)
		
	# Don't resume avatar motion if any enemies are
	# executing a move
	var is_any_enemy_executing: bool = live_enemies.any(func(a: Avatar): return a.battle_state == a.Battle_State.EXECUTING_MOVE)
		
	return not (is_any_party_member_acting or is_any_enemy_executing)

func resume_avatars_motion():
	var live_party_members = party_members.filter(func(a: Avatar): return a.is_alive)
	var live_enemies = enemy_avatars.filter(func(a: Avatar): return a.is_alive and a.battle_state == a.Battle_State.WAITING)
	
	for member in live_party_members:
		member.resume_motion = true
	for enemy in live_enemies:
		enemy.resume_motion = true

func on_start_order_step(actor: Actor) -> void:
	var avatar: Avatar = actor.avatar
	print("entering order step %s at time: %d" % [avatar.name, Time.get_ticks_msec()])
	avatar.progress_ratio = ORDER_STEP
	
	# entry point for party member to pick a move
	if avatar.avatar_type == Avatar.Avatar_Type.PARTY_MEMBER:
		# pause all timers to prevent them going off when party member is picking a move
		toggle_timer_tick(true)
		pause_avatars_motion()
		party_member_name.text = avatar.name
		action_layout.visible = true
		
		# Disconnect previous action connections 
		# avoids previous party member actions from being triggered
		Utility.disconnect_all_signal_connections(action_buttons.attack_button.pressed)
		Utility.disconnect_all_signal_connections(action_buttons.defend_button.pressed)
		Utility.disconnect_all_signal_connections(action_buttons.pick_skills_button.pressed)
		Utility.disconnect_all_signal_connections(action_buttons.flee_button.pressed)
		Utility.disconnect_all_signal_connections(avatar.battle_timers.flee_timer.timeout)

		for enemy in battle_manager.enemies:
			# Disconnect mob target selection and previous actor relationship
			var target_selection_area: MobSelection = enemy.get_target_selection_area()
			Utility.disconnect_all_signal_connections(target_selection_area.on_target_clicked)
			# Connect all possible enemy targets that can be clicked on when doing target selection
			var lambda = func(e: Actor, party_member: Actor): on_target_clicked(e, party_member)
			var output = target_selection_area.on_target_clicked.connect(lambda.bind(enemy, actor))
			print("connection result: %d" % output)
		
		action_buttons.attack_button.pressed.connect(_on_attack_button_pressed.bind(actor))
		action_buttons.defend_button.pressed.connect(_on_defend_button_pressed.bind(actor))
		action_buttons.pick_skills_button.pressed.connect(_on_skills_button_pressed.bind(actor))
		action_buttons.flee_button.pressed.connect(_on_flee_button_pressed.bind(actor))
		var conn = avatar.battle_timers.flee_timer.timeout.connect(on_determine_flee_rate.bind(actor))
		print("connected ? ", conn)
		
	# entry point for enemies to pick a move
	elif avatar.avatar_type == Avatar.Avatar_Type.ENEMY:
		ai_determine_move(avatar)
		#ai_use_random_skill(avatar)
		#ai_defend(avatar)
		#ai_flee(avatar)
		#ai_attack(avatar)

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
	print("ai_attack will be reworked once player commands are integrated")
		#var avatar: Avatar = actor.avatar
		#avatar.progress_ratio = 1
		## pick a random party member
		#var live_party_members: Array[Avatar] = party_members.filter(func(p: Avatar): return p.is_alive)
		#
		## no more party members to attack
		#if len(live_party_members) == 0:
			#return
		#
		#avatar.battle_state = avatar.Battle_State.EXECUTING_MOVE
		#avatar.update_battle_state_text()
		#
		#var i = randi_range(0, len(live_party_members) - 1)
		#var target: Avatar = live_party_members[i]
		#var dmg = battle_manager.damage_calculator.calculate_damage(target, avatar)
		#target.curr_stats.hp = maxi(target.curr_stats.hp - dmg, 0)
		#
		#battle_manager.damage_calculator.on_damage_received.emit(target, avatar)
		#
		## target downed...
		#if target.curr_stats.hp <= 0:
			#target.curr_stats.hp = 0
			## reset their timeline back to 0
			#target.progress_ratio = 0
			#target.resume_motion = false
			#target.is_alive = false
			#
		#
		## display damage dealt to target
		#description_panel.visible = true
		#label.text = "%s dealt %d damage to %s" % [avatar.name, dmg, target.name]
		#
		#BattleSignals.on_end_turn.emit(avatar)

func ai_defend(avatar: Avatar) -> void:
	print("ai_defend will be reworked once player commands are integrated")
	avatar.curr_stats.defense += avatar.curr_stats.defense * .25
	avatar.progress_ratio = 1
	avatar.resume_motion = false
	description_panel.visible = true
	label.text = "%s is defending" % [avatar.name]
	
	avatar.battle_state = avatar.Battle_State.EXECUTING_MOVE
	avatar.update_battle_state_text()
	
	avatar.battle_timers.defense_timer.start()

func ai_flee(avatar: Avatar) -> void:
	print("ai_flee will be reworked once player commands are integrated")
	#description_panel.visible = true
	#label.text = "%s fled from battle" % avatar.name
	#description_timer.start()
	#
	#avatar.on_avatar_flee.emit()
	#
	#var i = 0
	#while i < len(enemy_avatars):
		#if enemy_avatars[i] == avatar:
			#break
		#i += 1
		#
	## remove avatar from scene if found
	#if i < len(enemy_avatars):
		#enemy_avatars.remove_at(i)
		#remove_child(avatar)
		#avatar.queue_free()

func ai_use_random_skill(avatar: Avatar) -> void:
	# compute skill exec speed 
	# numerator is the difference b/w the progress_ratios ranging between 0 and 1 inclusive
	# denominator is the time period that the skill will take to execute measured in seconds
	var diff: float = 1 - avatar.progress_ratio
	var skill_exec_speed: float = diff / avatar.battle_timers.skill_timer.wait_time
	
	print("avatar %s start skill at time %d" % [avatar.name, Time.get_ticks_msec()])
	
	avatar._curr_speed = skill_exec_speed
	avatar.battle_state = avatar.Battle_State.PENDING_MOVE
	avatar.update_battle_state_text()
	avatar.battle_timers.skill_timer.start()

func on_ai_skill_end(avatar: Avatar) -> void:
	print("on_ai_skill_end will be reworked once player commands are integrated")
	#print("avatar %s skill end at time %d" % [avatar.name, Time.get_ticks_msec()])
	## pick random skill
	#var skill1 = Skill.new(1, 5, "Sizzle")
	#var skill2 = Skill.new(4, 10, "Spitfire")
	#var skill3 = Skill.new(8, 20, "Oven Overload")
	#
	## TODO: check ahead of time if enemy can cast a skill, if not, don't do this action
	#var skills: Array[Skill] = [skill1, skill2, skill3]
	#var castable_skills: Array[Skill] = skills.filter(func(s: Skill): return s.cost <= avatar.curr_stats.skill_points)
	#
	## pick random target to cast skill on
	#var members: Array[Avatar] = party_members.filter(func(p: Avatar): return p.is_alive)
	#
	#description_panel.visible = true
	#
	## no party members alive...
	#if len(members) == 0:
		#label.text = "%s no target to cast..." % avatar.name
		#return
		#
	#if len(castable_skills) == 0:
		#label.text = "%s cannot execute any skills!" % avatar.name
		#return
	#
	#var skill_index: int = randi_range(0, len(castable_skills) - 1)
	#var target_index: int = randi_range(0, len(members) - 1)
	#var target: Avatar = members[target_index]
	#var skill: Skill = skills[skill_index]
	#
	#var dmg = battle_manager.damage_calculator.calculate_damage(target, avatar)
	#
	#var text = "%s used %s on %s! It dealt %d damage" % [avatar.name, skill.name, target.name, dmg]
	#label.text = text 
	#
	#target.curr_stats.hp = maxi(target.curr_stats.hp - dmg, 0)
	#avatar.curr_stats.skill_points = maxi(avatar.curr_stats.skill_points - skill.cost, 0)
	#
	#battle_manager.damage_calculator.on_damage_received.emit(target, avatar)
	#
	## pause movement momentarily
	#avatar.resume_motion = false
	#avatar._curr_speed = avatar.move_speed
#
	#BattleSignals.on_end_turn.emit(avatar)

#endregion

func on_party_member_skill_end(dr_actor: Actor, dd_actor: Actor):
	var damage_receiver: Avatar = dr_actor.avatar
	var damage_dealer: Avatar = dd_actor.avatar
	
	# TODO may need to hold which avatar skill started in an array
	description_panel.visible = true
	var skill: Skill = pending_skill
	
	print("on party member skill end %s" % damage_dealer.name)
	# pass in damage dealer and damage receiver and skill used to compute damage taken
	var enemy_name := damage_receiver.name
	var skill_name := skill.name
	var dmg := skill.attack
	
	# TODO: Add damage calculations for skills
	damage_receiver.curr_stats.hp = maxi(damage_receiver.curr_stats.hp - dmg, 0)
	battle_manager.damage_calculator.on_damage_received.emit(damage_receiver, damage_dealer)
	label.text = "%s casts %s to %s. It deals %d damage!" % [damage_dealer.name, skill_name, enemy_name, dmg]
	
	# display damage description
	description_timer.start()
	BattleSignals.on_end_turn.emit(dd_actor)

func ui_on_damage_received(damage_receiver: Actor, damage_dealer: Actor, damage: int):
	var dd_avatar: Avatar = damage_dealer.avatar
	var dr_avatar: Avatar = damage_receiver.avatar
	print("ui on damage received: %s atks %s" % [dd_avatar.curr_stats.name, dr_avatar.curr_stats.name])
	
	if dd_avatar.avatar_type == Avatar.Avatar_Type.PARTY_MEMBER:
		target_menu.visible = false
		description_panel.visible = true
		# start timer to hide description panel
		description_timer.start()
		
		label.text = "%s attacked for %d damage to %s" % [dd_avatar.curr_stats.name, damage, dr_avatar.curr_stats.name]
		
		dd_avatar.battle_state = Constants.Battle_State.EXECUTING_MOVE
		dd_avatar.update_battle_state_text()
		# need to fix function signature damage_calculator on_damage_received and for all its call refs
		BattleSignals.on_end_turn.emit(damage_dealer)
