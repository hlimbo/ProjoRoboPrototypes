extends Node2D
class_name Actor

# Type Aliases through singleton script constants
const Ui_Battle_State = Constants.Battle_State
const Active_Battle_State = Constants.Active_Battle_State

@export var actor_type: Constants.Actor_Type

# battle_manager class self-injects itself into this class as it creates Actor instances
@export var battle_manager: BattleManager
@onready var damage_calculator: IDamageCalculator
@onready var info_node: InfoDisplay = get_info_display()

# Used when debugging in isolation
#@onready var damage_calculator: IDamageCalculator = BattleSceneManager.damage_calculator

@export var move_speed: float
@export var target: Node2D
var original_target: Node2D
@export var battle_state = Ui_Battle_State.WAITING
@export var motion_state = Active_Battle_State.NEUTRAL
# TODO - move curr_stats and initial_stats from avatar to here
@export var avatar: Avatar

var active_battle_state_machine: Fsm = Fsm.new()

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
# used to display basict attack damage text from UI
var on_attack_damage_text_updated: Callable
@onready var defense_timer: Timer = $Timers/DefenseTimer

@onready var defense_node: Node2D = $Defense

# quick time defend
@onready var battle_reaction: BattleReaction = $BattleReaction
@onready var reaction_based_button: ReactionBasedButton = $ReactionBasedButton
@onready var reaction_label: Control = $ReactionLabel

var flee_time: float = 0.0
@export var flee_fade_time: float = 3.0

@export var skill_cast_range: float = 100.0
var lightning_placeholder: Resource = preload("res://nodes/lightning.tscn")
var active_skill: Skill
var on_skill_damage_calculation: Callable
@onready var skill_placeholder_socket: Marker2D = $Sockets/SkillPlaceholderSocket
@export var is_skill_casted: bool = false

@export var is_quick_time_defend: bool = false

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
	
	active_battle_state_machine.current_state = Constants.Active_Battle_State.NEUTRAL
	active_battle_state_machine.init_state_map({
		Constants.Active_Battle_State.NEUTRAL: NeutralState.new(self),
		Constants.Active_Battle_State.MOVING: MovingState.new(self),
		Constants.Active_Battle_State.DEFEND: DefendState.new(self),
		Constants.Active_Battle_State.ATTACK: AttackState.new(self),
		Constants.Active_Battle_State.SKILL: SkillState.new(self),
		Constants.Active_Battle_State.FLEE: FleeState.new(self),
		Constants.Active_Battle_State.HURT: HurtState.new(self),
		Constants.Active_Battle_State.KNOCKBACK: KnockbackState.new(self),
		Constants.Active_Battle_State.CAST_SKILL: CastSkillState.new(self),
	})

func _ready():
	print("actor ready called: %s" % name)
	original_pos = position
	original_target = target
	
	init_collision_layer_interactions()
	# set all child canvas items to inherit shader from art root
	set_descendant_material_as_root_material()
	
	# flip attack hitbox for enemy
	if actor_type == Constants.Actor_Type.ENEMY:
		var hit_shape_node = get_node("CollisionGeometry/HitArea2D/CollisionShape2D")
		(hit_shape_node as CollisionShape2D).position.x *= -1
	
		# disable quick time event for enemy
		reaction_based_button.is_enabled = false
	
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
	
	
	if info_node and avatar:
		info_node.update_labels(avatar)
		
	connect_battle_signals()
	BattleSignals.on_end_turn.connect(disable_quick_time)
	add_child(active_battle_state_machine)


func connect_defend_reaction_button():
	if reaction_based_button:
		var on_key_pressed = func(reaction_state: ReactionBasedButton.ReactionState):
			var label = reaction_label.get_node("Label") as Label
			reaction_label.visible = true
			if reaction_state == ReactionBasedButton.ReactionState.ON_TIME:
				label.text = "Right On!"
				is_quick_time_defend = true
				# TODO: create a quick time defend command as it functions differently from the standard defend button command
				var def_cmd = DefendCommand.new()
				def_cmd.execute(self)
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

# GOAL: move each state specific logic into its own state class do handle its own processing there
func _physics_process(delta_time: float):
	if motion_state == Active_Battle_State.MOVING:
		if is_instance_valid(target) and !target.is_queued_for_deletion():
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
			
	elif motion_state == Active_Battle_State.SKILL:
		if target:
			var vel: Vector2 = move_to_target(target.position)
			position += vel * delta_time
			var dist: float = position.distance_to(target.position)
			if dist <= skill_cast_range:
				motion_state = Active_Battle_State.CAST_SKILL
				
	elif motion_state == Active_Battle_State.CAST_SKILL:
		# stop calling this once per frame... only call this once
		if is_skill_casted:
			return
		
		is_skill_casted = true
		# spawn lightning effect
		var lightning: Sprite2D = lightning_placeholder.instantiate()
		
		if skill_placeholder_socket:
			skill_placeholder_socket.add_child(lightning)
			# hack - rotate 180 degrees since enemy in battle scene is facing left
			if actor_type == Constants.Actor_Type.ENEMY:
				lightning.rotation_degrees = 180 
		
		# deal damage to target
		if on_skill_damage_calculation and not on_skill_damage_calculation.is_null():
			var has_no_valid_function: bool = on_skill_damage_calculation.call()
			if has_no_valid_function:
				print_rich("[color=red]No Valid function for on_skill_damage_calculation...[/color]")
		
		# destroy lightning effect after 3 seconds
		var on_lightning_disappear = func():
			lightning.queue_free()
			motion_state = Active_Battle_State.MOVING
			target = null
			is_skill_casted = false
			
		get_tree().create_timer(3).timeout.connect(on_lightning_disappear)
		
		# hack to tell that there is no function assigned to this callable as gdscript
		# does not support null Callables...
		on_skill_damage_calculation = func(): return true

func start_motion(target_actor: Actor):
	
	# if already moving don't trigger it again
	if motion_state == Active_Battle_State.MOVING:
		return
		
	print("start motion ", avatar.curr_stats.name)
	# turn on interact area to detect when an attack animation can be simulated
	interact_area.monitoring = true
	motion_state = Active_Battle_State.MOVING
	target = target_actor

func start_motion_skill(target_actor: Actor, skill: Skill, on_damage_calculation: Callable):
	if motion_state == Active_Battle_State.SKILL:
		return
		
	# allow actor movement when using a skill
	resume_motion = true
	motion_state = Active_Battle_State.SKILL
	target = target_actor
	active_skill = skill
	on_skill_damage_calculation = on_damage_calculation

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
		
	## stop moving towards actor to attack if attack is cancelled by another attack source
	#if is_attacked:
		#is_attacked = false
		#print("cancelling attack for %s" % avatar.curr_stats.name)
		#return
	
	print("on other entered ", avatar.curr_stats.name)
	if motion_state == Active_Battle_State.MOVING:
		print("entered attacking area: %s" % other.name)
		motion_state = Active_Battle_State.ATTACK
		# simulate attack animation delay -- timer
		enable_attack_timer.start()

# outer area - disable for now until quick time defend command is created
func on_outer_area_entered(area: Area2D):
	if actor_type == Constants.Actor_Type.PARTY_MEMBER:
		print("party member entered outer area")
	
	var is_valid_state: bool = [Active_Battle_State.NEUTRAL, Active_Battle_State.DEFEND].has(motion_state)
	if actor_type == Constants.Actor_Type.PARTY_MEMBER and is_valid_state:
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
			other_actor.on_disable_quick_time_defend.connect(disable_quick_time, ConnectFlags.CONNECT_ONE_SHOT)
			BattleSignals.on_quick_time_defend_pressed_valid.emit()
		else:
			print_rich("[color=red]Could not find other actor here on_outer_area_entered[/color]")

func on_attack_end():
	# attack should not end as it got cancelled...
	if motion_state == Active_Battle_State.KNOCKBACK:
		return
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
		
		var actor_receiving_dmg: Actor = target
		
		if actor_receiving_dmg == null:
			print_rich("[color=red]Unable to find actor to damage for %s[/color]" % avatar.curr_stats.name)
			BattleSignals.on_end_turn.emit(self)
			return
		
		# disable quick_time defend for party member as enemy since enemy owns their own hitbox
		if actor_type == Constants.Actor_Type.PARTY_MEMBER:
			actor_receiving_dmg.on_disable_quick_time_defend.emit()
			BattleSignals.on_quick_time_defend_late.emit()
		
		print("%s on attack connect %s" % [avatar.curr_stats.name, actor_receiving_dmg.avatar.name])
		
		var damage_receiver: Avatar = actor_receiving_dmg.avatar
		var damage_dealer: Avatar = avatar
		
		var dmg = damage_calculator.calculate_damage(actor_receiving_dmg, self)
		damage_receiver.curr_stats.hp = maxi(damage_receiver.curr_stats.hp - dmg, 0)
		damage_calculator.on_damage_received.emit(actor_receiving_dmg, self, dmg)
		
		print("on damage received basic attack: %s atks %s for %d dmg" % [damage_dealer.curr_stats.name, damage_receiver.curr_stats.name, dmg])
		
		# TODO: need to know what action the actor picked in order to print out the appropriate message for attack or skill
		var text = "%s attacked %s for %d damage" % [damage_dealer.curr_stats.name, damage_receiver.curr_stats.name, dmg]
		if !on_attack_damage_text_updated.is_null():
			if on_attack_damage_text_updated.call(text):
				print_rich("[color=red]on_attack_damage_text_updated has invalid function reference... ensure it is set before calling[/color]")
			
			# hack to unset function call
			on_attack_damage_text_updated = func(_text: String): return true
		
		# only interrupt motion if not defending or using a skill
		if not [Active_Battle_State.DEFEND, Active_Battle_State.SKILL].has(actor_receiving_dmg.motion_state):
			# cancel actor's attack if also attacking at the same time
			if actor_receiving_dmg.motion_state == Constants.Active_Battle_State.ATTACK:
				self.on_interrupt_motion(actor_receiving_dmg, Constants.Battle_State.KNOCKBACK)
			else:
				self.on_interrupt_motion(actor_receiving_dmg, Constants.Battle_State.PAUSED)
	else:
		print_rich("[color=red]Damage Calculator is null in Actor.gd[/color]")

func start_defend():
	defense_node.visible = true
	defense_timer.start()
	
func on_defend_end():
	motion_state = Active_Battle_State.NEUTRAL
	active_battle_state_machine.transition_to(Constants.Active_Battle_State.NEUTRAL)
	# hack - only end turn if not quick time defend
	if not is_quick_time_defend:
		BattleSignals.on_end_turn.emit(self)

func begin_flee():
	if motion_state == Active_Battle_State.FLEE:
		return
		
	flee_time = 0.0
	motion_state = Active_Battle_State.FLEE

func get_info_display() -> InfoDisplay:
	return get_node("HUD/InfoNode")
	
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
	var old_motion_state: Active_Battle_State = interruptee.motion_state
	interruptee.avatar.battle_state = new_battle_state
	
	if new_battle_state == Constants.Battle_State.PAUSED:
		interruptee.motion_state = Active_Battle_State.HURT
	elif new_battle_state == Constants.Battle_State.KNOCKBACK:
		interruptee.motion_state = Constants.Active_Battle_State.KNOCKBACK
		interruptee.active_battle_state_machine.transition_to(Constants.Active_Battle_State.KNOCKBACK)
	
	avatar.on_interrupt_motion(interruptee.avatar, new_battle_state)
	
	
func pause_motion_for(seconds_to_pause: float, old_motion_state: Active_Battle_State):
	var process_on_physics_tick: bool = true
	# TODO: may need different levels of "pausing"
	# one where the pause happens when party member is picking an action and another when a skill is being used
	var pause_timer: SceneTreeTimer = get_tree().create_timer(seconds_to_pause, true, process_on_physics_tick)
	toggle_motion(true)
	
	var on_restore_motion = func():
		print("resuming actor motion for ", avatar.curr_stats.name)
		toggle_motion(false)
		# subtle bug I introduced here... if actor gets interrupted by an attack while its casting is skill
		# it will go back to the neutral state as it hasn't done anything yet which is incorrect
		# it should stay in the SKILL state
		if motion_state != Active_Battle_State.SKILL:
			motion_state = old_motion_state
	
	pause_timer.timeout.connect(on_restore_motion)
 
func on_cancel_move():
	if avatar:
		avatar.is_knocked_back = false
		toggle_motion(false)
		
	# cancel attacks that did not connect
	target = null
	toggle_hitbox(false)
	interact_area.monitoring = false
	attack_timer.stop()
	
	# cancel skills that did not connect
	avatar.battle_timers.skill_timer.stop()
	Utility.disconnect_all_signal_connections(avatar.battle_timers.skill_timer.timeout)

func disable_quick_time(_actor: Actor):
	if battle_reaction:
		battle_reaction.visible = false


# using recursion (dfs), set all art nodes to inherit from parent material object
# saves time needing to click on all art assets to have a shader effect enabled
func set_descendant_material_as_root_material():
	var root_node = get_node("ArtRoot")
	_set_descendant_material_as_root_material_helper(root_node)
	
func _set_descendant_material_as_root_material_helper(curr_node: Node):
	# base case
	if curr_node == null:
		return
	
	var canvas_item: CanvasItem = curr_node as CanvasItem
	if canvas_item == null:
		return
	
	curr_node.use_parent_material = true
	var children: Array[Node] = curr_node.get_children()
	for child in children:
		_set_descendant_material_as_root_material_helper(child)

# for each collilsion geometry, set its layer and masks based on actor type
# https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html#collision-layers-and-masks
func init_collision_layer_interactions():
	# collision layers - bits
	const ALL: int = 0b1
	const PLAYER: int = 0b10
	const ENEMY: int = 0b100
	const PLAYER_INTERACT_RANGE: int = 0b1000
	const ENEMY_INTERACT_RANGE: int = 0b1_0000
	const PLAYER_ATTACK: int = 0b10_0000
	const ENEMY_ATTACK: int = 0b100_0000
	const LAYER_8: int = 0b1000_0000
	
	var interact_area: Area2D = get_node("CollisionGeometry/InteractArea")
	var outer_interact_area: Area2D = get_node("CollisionGeometry/OuterInteractArea")
	var hit_area: Area2D = get_node("CollisionGeometry/HitArea2D")
	var actor_area: Area2D = get_node("CollisionGeometry/ActorArea")
	var target_selection_area: Area2D = get_node("CollisionGeometry/TargetSelectionArea")
	
	if actor_type == Constants.Actor_Type.PARTY_MEMBER:
		interact_area.collision_layer = PLAYER_INTERACT_RANGE
		interact_area.collision_mask = ENEMY
		
		outer_interact_area.collision_layer = ALL
		outer_interact_area.collision_mask =  ALL
		
		hit_area.collision_layer = PLAYER_ATTACK
		hit_area.collision_mask = ENEMY
		
		actor_area.collision_layer = PLAYER
		actor_area.collision_mask = ALL | ENEMY_INTERACT_RANGE | ENEMY_ATTACK
		
		target_selection_area.collision_layer = LAYER_8
		target_selection_area.collision_mask = LAYER_8
	elif actor_type == Constants.Actor_Type.ENEMY:
		interact_area.collision_layer = ENEMY_INTERACT_RANGE
		interact_area.collision_mask = PLAYER
		
		outer_interact_area.collision_layer = ALL
		outer_interact_area.collision_mask =  ALL
		
		hit_area.collision_layer = ENEMY_ATTACK
		hit_area.collision_mask = PLAYER
		
		actor_area.collision_layer = ENEMY
		actor_area.collision_mask = ALL | PLAYER_INTERACT_RANGE | PLAYER_ATTACK
		
		target_selection_area.collision_layer = LAYER_8
		target_selection_area.collision_mask = LAYER_8
