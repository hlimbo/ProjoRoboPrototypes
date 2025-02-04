extends Node2D
class_name Actor

# Type Aliases through singleton script constants
const Ui_Battle_State = Constants.Battle_State
const Active_Battle_State = Constants.Active_Battle_State
const Avatar_Type = Constants.Avatar_Type

@export var avatar_type: Avatar_Type

# battle_manager class self-injects itself into this class as it creates Actor instances
@export var battle_manager: BattleManager
@onready var damage_calculator: IDamageCalculator
@onready var info_node: InfoDisplay = $InfoNode

# Used when debugging in isolation
#@onready var damage_calculator: IDamageCalculator = BattleSceneManager.damage_calculator

@export var move_speed: float
@export var target: Node2D
var original_target: Node2D
@export var battle_state = Ui_Battle_State.WAITING
@export var motion_state = Active_Battle_State.NEUTRAL
# TODO - move curr_stats and initial_stats from avatar to here
@export var avatar: Avatar


@export_group("Debug Menu")
@export var enable_debug_menu: bool

var original_pos: Vector2
# controls if movement is allowed or not
var resume_motion: bool = true

# used to detect when actor can stop moving
@onready var interact_area: Area2D = $CollisionGeometry/InteractArea
# used to detect actor's hitbox when attacking
@onready var hit_area: Area2D = $CollisionGeometry/HitArea2D

# used to detect when actor may receive attacks or other status effects
@onready var actor_area: Area2D = $CollisionGeometry/ActorArea

# used to detect Quick Time Event (QTE) Defend
@onready var outer_interact_area: Area2D = $CollisionGeometry/OuterInteractArea

@onready var attack_timer: Timer = $Timers/AttackTimer
# TODO: once placeholder art with frames is in... could code it to where when a frame starts
# enable hitbox and on end frame disable hitbox
@onready var enable_attack_timer: Timer = $Timers/EnableAttackTimer
@onready var defense_timer: Timer = $Timers/DefenseTimer

@onready var defense_node: Node2D = $Defense

# quick time defend
@onready var battle_reaction: BattleReaction = $BattleReaction
@onready var reaction_based_button: ReactionBasedButton = $ReactionBasedButton
@onready var reaction_label: Control = $ReactionLabel

var flee_time: float = 0.0
@export var flee_fade_time: float = 3.0
@export var is_attacked: bool = false

#region Commands
var attack_cmd: AttackCommand
var defend_cmd: DefendCommand
var flee_cmd: FleeCommand
#endregion

signal on_disable_quick_time_defend

func _init():
	# These should be created as they are issued by button presses by player controller
	# or when AI issues these commands
	# leaving it here to keep things simple
	attack_cmd = AttackCommand.new()
	defend_cmd = DefendCommand.new()
	flee_cmd = FleeCommand.new()

func _ready():
	print("actor ready called: %s" % name)
	original_pos = position
	original_target = target
	
	# for some reason in between scene changes, the prev shader value persists...
	# resetting on scene ready
	(material as ShaderMaterial).set_shader_parameter("transparency_value", 1)
	info_node.visible = true
	
	if battle_manager:
		damage_calculator = battle_manager.damage_calculator
	
	if info_node:
		info_node.avatar = avatar
	
	if not interact_area or not attack_timer or not enable_attack_timer or not defense_timer or not hit_area:
		return
	
	attack_timer.timeout.connect(on_attack_end)
	enable_attack_timer.timeout.connect(on_enable_attack_hitbox)
	defense_timer.timeout.connect(on_defend_end)
	
	outer_interact_area.area_entered.connect(on_outer_area_entered)
	interact_area.area_entered.connect(on_other_entered)
	hit_area.area_entered.connect(on_attack_connect)
	
	#if avatar:
		#avatar.generate_random_stats()
	
	if info_node and avatar:
		info_node.update_labels(avatar)
		
	connect_battle_signals()
	the_reaction_button()


func the_reaction_button():
	if reaction_based_button:
		var on_key_pressed = func(reaction_state: ReactionBasedButton.ReactionState):
			var label = reaction_label.get_node("Label") as Label
			reaction_label.visible = true
			if reaction_state == ReactionBasedButton.ReactionState.ON_TIME:
				label.text = "Right On!"
				start_defend()
			elif reaction_state == ReactionBasedButton.ReactionState.EARLY:
				label.text = "Too Early!"
			elif reaction_state == ReactionBasedButton.ReactionState.LATE:
				label.text = "Too Late!"
			else:
				label.text = "Not Quite!"
				
			var hide_timer = Timer.new()
			add_child(hide_timer)
			hide_timer.one_shot = true
			hide_timer.wait_time = 3
			hide_timer.start()
			var on_timeout = func():
				reaction_label.visible = false
				hide_timer.queue_free()
			hide_timer.timeout.connect(on_timeout)
			
		
		reaction_based_button.on_key_pressed.connect(on_key_pressed)

func connect_battle_signals():
	if avatar:
		avatar.on_start_turn.connect(func(): BattleSignals.on_start_turn.emit(self))

func move_back_to_original_position(delta_time: float) -> float:
	# move back to original position
	var vel: Vector2 = move_to_target(original_pos)
	position += vel * delta_time
	var dist: float = position.distance_to(original_pos)
	return dist

func _process(delta_time: float):
	# player controls
	if (name == "yellow_mob2"):
		if (Input.is_action_pressed("attack")):
			attack_cmd.execute(self)
		elif (Input.is_action_pressed("defend")):
			defend_cmd.execute(self)
		elif (Input.is_action_pressed("flee")):
			flee_cmd.execute(self)
	# enemy controls
	elif (name == "enemy_placeholder"):
		if (Input.is_action_pressed("attack2")):
			attack_cmd.execute(self)
		elif (Input.is_action_pressed("defend2")):
			defend_cmd.execute(self)

func _physics_process(delta_time: float):
	if motion_state == Active_Battle_State.MOVING:
		if target:
			var vel: Vector2 = move_to_target(target.position)
			position += vel * delta_time
		else:
			var dist: float = move_back_to_original_position(delta_time)
			if dist <= 100:
				motion_state = Active_Battle_State.NEUTRAL
				BattleSignals.on_end_turn.emit(self)
	
	elif motion_state == Active_Battle_State.KNOCKBACK:
		var dist: float = move_back_to_original_position(delta_time)
		if dist <= 100:
			motion_state = Active_Battle_State.NEUTRAL
		
	elif motion_state == Active_Battle_State.FLEE:
		flee_time = clampf(flee_time + delta_time, flee_time, flee_fade_time)
		var diff: float = flee_fade_time - flee_time
		fadeout(diff)
		if diff == 0:
			avatar.is_alive = false

func start_motion(target_actor: Actor):
	
	# if already moving don't trigger it again
	if motion_state == Active_Battle_State.MOVING:
		return
		
	print("start motion ", avatar.curr_stats.name)
	# turn on interact area to detect when an attack animation can be simulated
	interact_area.monitoring = true
	motion_state = Active_Battle_State.MOVING
	target = target_actor

func move_to_target(target_pos: Vector2) -> Vector2:
	var dir = (target_pos - position).normalized()
	var velocity = Vector2(dir.x, dir.y) * move_speed * float(resume_motion)
	return velocity

# TODO: use groups to tag by party member and enemy
# inner area
func on_other_entered(other: Area2D):
	# turn off the interact area to prevent further overlap events from being triggered
	# one event should be triggered per single target attack
	interact_area.monitoring = false

	# if not target OR the other area2D isn't an actor's collision body, don't trigger the attack state
	if !target or target.get_node("CollisionGeometry/ActorArea") != other:
		return
		
	# stop moving towards actor to attack if attack is cancelled by another attack source
	if is_attacked:
		is_attacked = false
		print("cancelling attack for %s" % avatar.curr_stats.name)
		return
	
	print("on other entered ", avatar.curr_stats.name)
	if motion_state == Active_Battle_State.MOVING:
		print("entered attacking area: %s" % other.name)
		motion_state = Active_Battle_State.ATTACK
		# simulate attack animation delay -- timer
		enable_attack_timer.start()

# outer area
func on_outer_area_entered(area: Area2D):
	if avatar.avatar_type == Avatar_Type.PARTY_MEMBER:
		print("party member entered outer area")
	
	var is_valid_state: bool = [Active_Battle_State.NEUTRAL, Active_Battle_State.DEFEND].has(motion_state)
	if avatar.avatar_type == Avatar_Type.PARTY_MEMBER and is_valid_state:
		battle_reaction.visible = true
		
		# assumption: the Actor class is attached to the root node
		var node: Node = area
		print("node owner?? ", node.owner)
		# this climbs up all the way to the main node of the scene
		while node and node is not Actor and node.get_parent() != null:
			print("node now: ", node.name)
			node = node.get_parent()
			
		if node:
			var other_actor: Actor = node as Actor
			# disable exclamation point at a later time
			var disable_quick_time = func():
				battle_reaction.visible = false
			other_actor.on_disable_quick_time_defend.connect(disable_quick_time, ConnectFlags.CONNECT_ONE_SHOT)
			BattleSignals.on_quick_time_defend_pressed_valid.emit()
		else:
			print_rich("[color=red]Could not find other actor here on_outer_area_entered[/color]")

func on_attack_end():
	print("%s ending attack" % avatar.curr_stats.name)
	motion_state = Active_Battle_State.MOVING
	target = null
	toggle_hitbox(false)

# simulate enabling hit box at end of the frame
func on_enable_attack_hitbox():
	toggle_hitbox(true)
	# simulate attack animation
	attack_timer.start()

func on_attack_connect(area: Area2D):
	# apply damage calculations
	if damage_calculator:
		
		# disable quick_time defend for party member as enemy since enemy owns their own hitbox
		on_disable_quick_time_defend.emit()
		BattleSignals.on_quick_time_defend_late.emit()
		
		var actor_receiving_dmg: Actor = target
		
		if actor_receiving_dmg == null:
			print_rich("[color=red]Unable to find actor to damage for %s[/color]" % avatar.curr_stats.name)
			BattleSignals.on_end_turn.emit(self)
			return
		
		print("%s on attack connect %s" % [avatar.curr_stats.name, actor_receiving_dmg.avatar.name])
		
		var damage_receiver: Avatar = actor_receiving_dmg.avatar
		var damage_dealer: Avatar = avatar
		
		# I need to go back to the drawing board and think MORE on how I'd like to implement it....
		#actor_receiving_dmg.is_attacked = true
		var dmg = damage_calculator.calculate_damage(actor_receiving_dmg, self)
		damage_receiver.curr_stats.hp = maxi(damage_receiver.curr_stats.hp - dmg, 0)
		damage_calculator.on_damage_received.emit(actor_receiving_dmg, self, dmg)
		
		# only interrupt motion if not defending or using a skill
		if not [Active_Battle_State.DEFEND, Active_Battle_State.SKILL].has(actor_receiving_dmg.motion_state):
			## cancel actor's attack if also attacking at the same time
			#if actor_receiving_dmg.motion_state == Constants.Active_Battle_State.ATTACK:
				#self.on_interrupt_motion(actor_receiving_dmg, Constants.Battle_State.KNOCKBACK)
			#else:
			self.on_interrupt_motion(actor_receiving_dmg, Constants.Battle_State.PAUSED)
	else:
		print_rich("[color=red]Damage Calculator is null in Actor.gd[/color]")

func start_defend():
	if motion_state == Active_Battle_State.DEFEND:
		return
	
	motion_state = Active_Battle_State.DEFEND
	if avatar:
		avatar.curr_stats.defense += avatar.curr_stats.defense * 0.25
		print ("%s defense is now at %d" % [avatar.curr_stats.name, avatar.curr_stats.defense])

	defense_node.visible = true
	defense_timer.start()
	
func on_defend_end():
	if avatar:
		avatar.curr_stats.defense = avatar.initial_stats.defense
		print ("%s defense end with def at %d" % [avatar.curr_stats.name, avatar.curr_stats.defense])
	
	defense_node.visible = false
	motion_state = Active_Battle_State.NEUTRAL
	BattleSignals.on_end_turn.emit(self)

func begin_flee():
	if motion_state == Active_Battle_State.FLEE:
		return
		
	flee_time = 0.0
	motion_state = Active_Battle_State.FLEE

func get_info_display() -> InfoDisplay:
	return get_node("InfoNode")
	
# enemy actors can only access this
func get_target_selection_area() -> MobSelection:
	return get_node("CollisionGeometry/TargetSelectionArea")

# TODO: once animation frames are added in, add it functionality to freeze frames
func toggle_motion(is_paused: bool):
	toggle_timers(is_paused)
	resume_motion = !is_paused
	
	if avatar:
		avatar.toggle_motion(is_paused)
	
func toggle_hitbox(is_enabled: bool):
	hit_area.monitoring = is_enabled

func toggle_timers(is_paused: bool):
	attack_timer.paused = is_paused
	enable_attack_timer.paused = is_paused
	defense_timer.paused = is_paused

func fadeout(t: float):
	(material as ShaderMaterial).set_shader_parameter("transparency_value", t)
	info_node.visible = false

func get_reaction_button() -> ReactionBasedButton:
	return reaction_based_button
	
func on_interrupt_motion(interruptee: Actor, new_battle_state: Constants.Battle_State):
	var old_avatar_state: Constants.Battle_State = interruptee.avatar.battle_state
	var old_motion_state: Active_Battle_State = interruptee.motion_state
	interruptee.avatar.battle_state = new_battle_state
	
	if new_battle_state == Constants.Battle_State.PAUSED:
		avatar.on_interrupt_motion(interruptee.avatar, old_avatar_state)
		interruptee.motion_state = Active_Battle_State.HURT
		var seconds_to_pause: float = 3
		interruptee.pause_motion_for(seconds_to_pause, old_motion_state)
	elif new_battle_state == Constants.Battle_State.KNOCKBACK:
		interruptee.motion_state = Constants.Active_Battle_State.KNOCKBACK
		# cancel pending actions such as basic attack or skill
		interruptee.on_cancel_move()
		
		avatar.on_interrupt_motion(interruptee.avatar, old_avatar_state)
		var seconds_to_knockback: float = 0.5
		# Simulate knockback animation
		interruptee.pause_motion_for(seconds_to_knockback, Constants.Active_Battle_State.MOVING)
		
func pause_motion_for(seconds_to_pause: float, old_motion_state: Active_Battle_State):
	var process_on_physics_tick: bool = true
	# TODO: may need different levels of "pausing"
	# one where the pause happens when party member is picking an action and another when a skill is being used
	var pause_timer: SceneTreeTimer = get_tree().create_timer(seconds_to_pause, true, process_on_physics_tick)
	toggle_motion(true)
	
	var on_restore_motion = func():
		print("resuming actor motion for ", name)
		toggle_motion(false)
		motion_state = old_motion_state
	
	pause_timer.timeout.connect(on_restore_motion)
 
func on_cancel_move():
	if avatar:
		avatar.is_knocked_back = false
		toggle_motion(false)
		# cancel pending skills
		avatar.battle_timers.skill_timer.stop()
		Utility.disconnect_all_signal_connections(avatar.battle_timers.skill_timer.timeout)
		
	# cancel attacks that did not connect
	target = null
	toggle_hitbox(false)
	interact_area.monitoring = false
