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

@onready var transition_rect: ColorRect = $TransitionRect
@onready var transition_label: Label = $TransitionRect/Label

@onready var no_op: Button

@onready var battle_results_screen: BattleResultsController = $BattleResultsScreen
@onready var one_d_graph: Control = $OneDGraph


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

@export var party_battle_state: Party_Battle_States = Party_Battle_States.IN_PROGRESS

var battle_controller: BattleController
var action_buttons: BattleController.ActionButtons

var attack_type: Attack_Type
var pending_skill: Skill

func on_end_turn(actor: Actor):
	description_timer.start()
	actor.avatar.battle_timers.resume_delay_timer.start()
	
	# reset attack state to prevent future attacks from this actor from being cancelled
	# actor.is_attacked = false

func on_resume_play():
	resume_actors_motion()

func _ready():
	
	print("ui controller ready called")
	battle_controller = BattleController.new()
	action_buttons = BattleController.ActionButtons.new()
	action_buttons.init(attack, skill_btn, defend, flee, cancel)
	
	cancel.pressed.connect(_on_cancel_button_pressed)
	target_cancel.pressed.connect(_on_cancel_button_pressed)
	no_op = action_layout.get_node("ActionLayout/No-op") as Button
		
	for enemy in battle_spawn_manager.get_enemies():
		enemy.get_target_selection_area().on_target_hovered.connect(on_target_hovered)
		enemy.get_target_selection_area().on_target_unhovered.connect(on_target_unhovered)
	
	# 1-d graph
	BattleSignals.on_end_turn.connect(on_end_turn)
	BattleSignals.on_resume_play.connect(on_resume_play)
	BattleSignals.on_start_turn.connect(on_start_order_step)
	
	battle_manager.damage_calculator.on_damage_received.connect(on_show_description_panel)
	battle_manager.damage_calculator.on_damage_received.connect(on_check_damage_receiver_is_defeated)
	
	
	# for camera motions
	original_cam_pos = camera_2d.position

func toggle_pickable_mobs(input_pickable: bool):
	# pick target to attack
	# enable as pickable which accepts mouse pointer events
	for enemy in battle_spawn_manager.get_enemies():
		enemy.get_target_selection_area().input_pickable = input_pickable

func _on_attack_button_pressed(_actor: Actor):
	action_layout.visible = false
	toggle_pickable_mobs(true)
	# switch to attack selection menu
	target_menu.visible = true
	attack_type = Attack_Type.BASIC

func _on_skills_button_pressed(actor: Actor):
	active_skill_menu.visible = true
	action_layout.visible = false
	
	skill_controller.lazy_load_skills(actor)
	attack_type = Attack_Type.SKILL

func start_defend(actor: Actor):
	var avatar: Avatar = actor.avatar
	label.text = "%s is defending!" % avatar.avatar_data.avatar_name
	
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

func on_no_op_pressed(actor: Actor):
	target_menu.visible = false
	active_skill_menu.visible = false
	action_layout.visible = false
	
	var no_op_cmd = NoOpCommand.new()
	no_op_cmd.execute(actor)

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
		battle_spawn_manager.remove_actor(Constants.Actor_Type.ENEMY, enemy)
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
		did_tween_start = true
		end_battle()

func end_battle():
	# disable avatars
	for avatar in battle_spawn_manager.get_party_member_avatars():
		avatar.disable()
	for avatar in battle_spawn_manager.get_enemy_avatars():
		avatar.disable()
		
	# disable actors
	for actor in battle_spawn_manager.get_all_actors():
		actor.disable()
	
	# hide timeline
	one_d_graph.visible = false
	
	var party_members: Array[Actor] = battle_spawn_manager.get_party_members()
	assert(len(party_members) > 0)
	
	var delay_time_sec: float = party_members[0].flee_fade_time + 0.5
	var delay_timer: SceneTreeTimer = get_tree().create_timer(delay_time_sec, false, true)
	var on_display_end_battle_screen = func():
		display_end_battle_screen(party_battle_state)
	delay_timer.timeout.connect(on_display_end_battle_screen)

func on_determine_flee_rate(actor: Actor):
	# TODOs
	# - change scene to the overworld scene when successfully fled from battle
	# - figure out a formula that takes difference between your party's avg level
	# and enemies avg level into consideration for when a flee will be successful
	
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
	# TODO: add back in once pending move state is more configurable
	# avatar.ui_battle_state_machine.transition_to(Constants.Battle_State.PENDING_MOVE)
	
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
	var damage_dealer: Avatar = dd_actor.avatar
	
	if attack_type == Attack_Type.BASIC:
		var atk_cmd = AttackCommand.new()
		atk_cmd.target = dr_actor
		var wrapper = func(text: String) -> bool:
			label.text = text
			return false
		atk_cmd.on_label_text_update = wrapper
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

func pause_actors_motion_excluding(actors: Array[Actor]):
	var party_members: Array[Actor] = battle_spawn_manager.get_party_members()
	var enemies: Array[Actor] = battle_spawn_manager.get_enemies()
	
	var live_party_members = party_members.filter(func(a: Actor): return a.avatar.is_alive)
	var live_enemies = enemies.filter(func(a: Actor): return a.avatar.is_alive)
	
	description_timer.paused = true
	battle_timer_manager.pause_actors_excluding(live_party_members, actors)
	battle_timer_manager.pause_actors_excluding(live_enemies, actors)

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
	
	# on start of turn, apply any buffs/debuffs that this actor has and remove them
	# when their durations are up
	actor.status_effects_component.update_status_effects_turn_counts()
	
	# entry point for party member to pick a move
	if avatar.avatar_type == Constants.Avatar_Type.PARTY_MEMBER:
		avatar.ui_battle_state_machine.transition_to(Constants.Battle_State.MOVE_SELECTION)
		
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
		Utility.disconnect_all_signal_connections(no_op.pressed)

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
		no_op.pressed.connect(on_no_op_pressed.bind(actor))
		
	# entry point for enemies to pick a move
	elif avatar.avatar_type == Constants.Avatar_Type.ENEMY:
		#ai_determine_move(actor)
		#ai_use_random_skill(actor)
		#start_defend(actor)
		#ai_flee(actor)
		ai_attack(actor)

func display_end_battle_screen(status: Party_Battle_States):
	match status:
		Party_Battle_States.FLEE:
			run_placeholder_transition(transition_rect,"Party Fled")
		Party_Battle_States.WIN:
			var on_battle_results_screen_visible = func():
				print("battle results screen visible")
				battle_results_screen.give_experience_to_party(100)
				battle_results_screen.generate_loot()
			
			battle_results_screen.visible = true
			battle_results_screen.z_index = 1
			tween_to_be_visible(battle_results_screen, on_battle_results_screen_visible)
		Party_Battle_States.DEFEAT:
			run_placeholder_transition(transition_rect, "Game Over")


func exit_scene():
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

func run_placeholder_transition(rect: ColorRect, text_label: String):
	transition_label.text = text_label
	rect.visible = true
	# need to set z-level to a higher value to hide the PartyPath2D avatar nodes
	rect.z_index = 1
	tween_to_be_visible(rect, exit_scene)


func tween_to_be_visible(rect: ColorRect, on_transition: Callable):
	var tween: Tween = get_tree().create_tween()
	# set tween alpha from 0 alpha to 1 alpha on the modulate property's alpha component
	tween.parallel().tween_property(rect, "modulate:a", 1, 1).from(0)
	tween.parallel().tween_property(rect,"self_modulate:a", 1, 1).from(0)
	tween.finished.connect(on_transition)

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
	var wrapper = func(text: String) -> bool:
		label.text = text
		return false
	# pick random target to attack
	var i = randi_range(0, len(live_party_members) - 1)
	# TEMP: always attack the first one
	var target: Actor = live_party_members[0]
	atk_cmd.target = target
	atk_cmd.on_label_text_update = wrapper
	atk_cmd.execute(actor)
	
func ai_flee(actor: Actor) -> void:
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
	
	pause_actors_motion_excluding([damage_dealer])
	
	print("avatar %s skill end at time %d" % [avatar.name, Time.get_ticks_msec()])
	# pick random skill
	var skill1 = Skill.new(1, "Sizzle")
	var skill2 = Skill.new(4, "Spitfire")
	var skill3 = Skill.new(8, "Oven Overload")
	
	# TODO: check ahead of time if enemy can cast a skill, if not, don't do this action
	var skillz: Array[Skill] = [skill1, skill2, skill3]
	var castable_skills: Array[Skill] = skillz.filter(func(s: Skill): return s.cost <= avatar.avatar_data.current_stats.skill_points)

	if len(castable_skills) == 0:
		description_panel.visible = true
		label.text = "%s cannot execute any skills!" % avatar.name
		return
	
	var skill_index: int = randi_range(0, len(castable_skills) - 1)
	var skill: Skill = skillz[skill_index]
	var wrapper = func() -> bool:
		return on_skill_damage_calculation(damage_dealer, damage_receiver, skill)
	
	var skill_cmd = SkillPlaceholderCommand.new()
	skill_cmd.target = damage_receiver
	skill_cmd.skill = skill
	skill_cmd.on_damage_calculation = wrapper
	skill_cmd.execute(damage_dealer)

#endregion

func on_party_member_skill_end(damage_receiver: Actor, damage_dealer: Actor):
	var target: Avatar = damage_receiver.avatar
	
	var excluded_actors: Array[Actor] = [damage_dealer]
	pause_actors_motion_excluding(excluded_actors)

	# TODO: connect skill used to button press that has skill information
	# var skill: Skill = pending_skill
	# TODO: temporary code to test skill creation and execution
	#var skill = Skill.new()
	#skill.name = "Mighty Goblin Punch"
	#skill.energy_type = "Electric"
	#skill.description = "Goblin Attack Hit!"
	#skill.cost = 12
	#
	#var base_dmg = Modifier.new()
	#base_dmg.stat_category_type_src = Constants.STAT_NONE
	#base_dmg.stat_category_type_target = Constants.STAT_HP
	#base_dmg.modifier_type = Constants.MODIFIER_FLAT
	#base_dmg.stat_value = -10
	#
	#var dmg_mod = Modifier.new()
	#dmg_mod.stat_category_type_src = Constants.STAT_TOUGHNESS
	#dmg_mod.stat_category_type_target = Constants.STAT_HP
	#dmg_mod.modifier_type = Constants.MODIFIER_PERCENT
	#dmg_mod.stat_value = -50
	#
	#skill.modifiers.append(base_dmg)
	#skill.modifiers.append(dmg_mod)
	
	# TODO: temporary code to test different skills for ease of testing
	var skill = Skill.new()
	skill.name = "Thorny Defense"
	skill.energy_type = "Wood"
	skill.description = "Performs guard action and deals wood damage back to opposing bot while guarding. Defense is increased and Speed is decreased while in this stance."
	skill.cost = 4
	
	var thorny_effect = StatusEffect.new()
	thorny_effect.name = "Thorny Defense"
	thorny_effect.description = "Deals flat damage back to enemies that attack this character"
	thorny_effect.duration_type = "SECONDS"
	thorny_effect.duration = 30
	thorny_effect.can_affect_self = false
	
	var dmg_modifier = Modifier.new()
	dmg_modifier.modifier_type = Constants.MODIFIER_FLAT
	dmg_modifier.stat_category_type_src = Constants.STAT_NONE
	dmg_modifier.stat_category_type_target = Constants.STAT_HP
	dmg_modifier.stat_value = 30
	thorny_effect.modifiers.append(dmg_modifier)
	
	# immediate modifiers - is treated as a status effect because the stat changes are temporary
	var thorny_effect_stat_buffs = StatusEffect.new()
	thorny_effect_stat_buffs.name = "Thorny Defense Stat Buffs"
	thorny_effect_stat_buffs.description = "Increases Defense but Decreases Speed temporarily"
	thorny_effect_stat_buffs.duration_type = "SECONDS"
	thorny_effect_stat_buffs.duration = 10
	thorny_effect_stat_buffs.can_affect_self = true
	
	var def_modifier = Modifier.new()
	def_modifier.stat_category_type_src = Constants.STAT_NONE
	def_modifier.stat_category_type_target = Constants.STAT_TOUGHNESS
	def_modifier.modifier_type = Constants.MODIFIER_FLAT
	def_modifier.stat_value = 50
	
	var spd_modifier = Modifier.new()
	spd_modifier.stat_category_type_src = Constants.STAT_NONE
	spd_modifier.stat_category_type_target = Constants.STAT_SPEED
	spd_modifier.modifier_type = Constants.MODIFIER_FLAT
	spd_modifier.stat_value = -25
	thorny_effect_stat_buffs.modifiers.append(def_modifier)
	thorny_effect_stat_buffs.modifiers.append(spd_modifier)
	
	skill.buffs.append(thorny_effect)
	skill.buffs.append(thorny_effect_stat_buffs)
	
	var wrapper = func() -> bool:
		return on_skill_damage_calculation(damage_dealer, damage_receiver, skill)

	# you can have an AOE skill, a single target skill, or a multi-target skill
	var skill_cmd = SkillPlaceholderCommand.new()
	skill_cmd.target = damage_receiver
	skill_cmd.skill = skill
	skill_cmd.on_damage_calculation = wrapper
	skill_cmd.execute(damage_dealer)

func on_show_description_panel(_damage_receiver: Actor, _damage_dealer: Actor, _damage: int):
	target_menu.visible = false
	description_panel.visible = true
	# start to begin hiding the description panel after some time passed
	description_timer.start()

	
func on_check_damage_receiver_is_defeated(damage_receiver: Actor, _damage_dealer: Actor, _damage: int):
	var dr_avatar: Avatar = damage_receiver.avatar
	
	# check if target is downed... no longer able to battle
	if dr_avatar.avatar_data.current_stats.hp <= 0:
		print("damage receiver %s is defeated!" % dr_avatar.avatar_data.avatar_name)
		dr_avatar.is_alive = false
		dr_avatar.avatar_data.current_stats.hp = 0
		dr_avatar.progress_ratio = 0
		damage_receiver.toggle_motion(true)
		dr_avatar.is_alive = false

func on_skill_attack_damage_received(_damage_receiver: Actor, damage_dealer: Actor, _damage: int):
	var dd_avatar: Avatar = damage_dealer.avatar
	
	description_panel.visible = true
	description_timer.start()
	dd_avatar.ui_battle_state_machine.transition_to(Constants.Battle_State.EXECUTING_MOVE)
	dd_avatar.battle_state = Constants.Battle_State.EXECUTING_MOVE

# bool is returned herBe because Godot doesn't do null callables... so this hack is here to
# check if function reference is null
# true == null function
# false == valid function
func on_skill_damage_calculation(damage_dealer: Actor, damage_receiver: Actor, skill: Skill) -> bool:
	print("on party member skill end %s" % damage_dealer.name)
	var target: Avatar = damage_receiver.avatar
	var avatar: Avatar = damage_dealer.avatar
	var enemy_name: String = target.avatar_data.avatar_name
	var skill_name: String = skill.name
	
	
	# Skills that damage others example
	var total_dmg: float = 0.0
	damage_dealer.skill_system_component.add_skill(skill) # grant skill to damage dealer
	#var deltas: Array[float] = damage_dealer.skill_system_component.activate_skill(skill.name, damage_receiver)
	## a bit hacky and needs to be removed from here....
	#total_dmg = deltas[0] # hp
	
	# Skills that affect self example - Thorny Defense
	# apply to self because thorny defense applied to self but affects other actors
	# that attack it
	damage_dealer.skill_system_component.thorny_defense(damage_dealer)
	
	
	label.text = "%s casts %s to %s. It deals %d damage!" % [avatar.avatar_data.avatar_name, skill_name, enemy_name, total_dmg]

	target.avatar_data.current_stats.hp = maxi(target.avatar_data.current_stats.hp - total_dmg, 0)
	battle_manager.damage_calculator.on_damage_received.emit(damage_receiver, damage_dealer, total_dmg)
	on_skill_attack_damage_received(damage_receiver, damage_dealer, total_dmg)
	
	#region testing status effects
	## TODO: remove as this is temporary code to test buffs and debuffs
	## give damage receiver an attack buff for 3 seconds
	##var buff = StatusEffect.new()
	##buff.name = "Strength Boost"
	##buff.duration_type = "SECONDS"
	##buff.is_applied_over_time = false
	##buff.duration = 3.0
	##var str_modifier = Modifier.new(Constants.STAT_NONE, Constants.STAT_STRENGTH, Constants.MODIFIER_FLAT, 10)
	##buff.modifiers.append(str_modifier)
	##damage_receiver.status_effects_component.add_buff(buff)
	#
	## give damage receiver a defend debuff for 6 seconds
	#var debuff = StatusEffect.new()
	#debuff.name = "Weaken"
	#debuff.is_applied_over_time = true
	#debuff.duration_type = "SECONDS"
	#debuff.duration = 6.0
	#var def_modifier = Modifier.new(Constants.STAT_NONE, Constants.STAT_TOUGHNESS, Constants.MODIFIER_FLAT, -6)
	#debuff.modifiers.append(def_modifier)
	#damage_receiver.status_effects_component.add_debuff(debuff)
	#
	## TODO: remove as this is temporary code to test buffs and debuffs
	## give damage receiver an attack buff for 3 seconds
	#var buff2 = StatusEffect.new()
	#buff2.name = "Strength 2 Turns"
	#buff2.duration_type = "TURN"
	#buff2.duration = 2
	#var str_modifier2 = Modifier.new(Constants.STAT_NONE, Constants.STAT_STRENGTH, Constants.MODIFIER_FLAT, 10)
	#buff2.modifiers.append(str_modifier2)
	#damage_receiver.status_effects_component.add_buff(buff2)
	#
	#var debuff2 = StatusEffect.new()
	#debuff2.name = "Weaken 4 Turns"
	#debuff2.duration_type = "TURN"
	#debuff2.duration = 4
	#var def_modifier2 = Modifier.new(Constants.STAT_NONE, Constants.STAT_TOUGHNESS, Constants.MODIFIER_FLAT, -6)
	#debuff2.modifiers.append(def_modifier2)
	#damage_receiver.status_effects_component.add_debuff(debuff2)
	#endregion
	
	if damage_receiver.motion_state != Constants.Active_Battle_State.DEFEND:
		damage_dealer.on_interrupt_motion(damage_receiver, Constants.Battle_State.KNOCKBACK)
		
	return false
