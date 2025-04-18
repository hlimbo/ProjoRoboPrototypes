extends Node2D
class_name Actor

# Type Aliases through singleton script constants
const Ui_Battle_State = Constants.Battle_State
const Active_Battle_State = Constants.Active_Battle_State

#region Dependencies
# battle_manager class self-injects itself into this class as it creates Actor instances
@export var battle_manager: BattleManager
@onready var damage_calculator: IDamageCalculator
@onready var info_node: InfoDisplay = get_info_display()

# Used when debugging in isolation
#@onready var damage_calculator: IDamageCalculator = BattleSceneManager.damage_calculator

#endregion

#region Components

@export var active_battle_state_machine: Fsm = Fsm.new()
@onready var skill_system_component: SkillSystemComponent = $SkillSystemComponent
@onready var status_effects_component: StatusEffectsComponent = $StatusEffectsComponent
# UI Component of actor in a battle scene
@export var avatar: Avatar

# These are used to reset current stat attributes back to before battle starts
# Base hp represents max hp
# These can be only modified when a level up occurs
@export var base_stat_attributes: StatAttributeSet
# These are a copy of base_stat_attributes at start of battle
# these can be modified as long as battle is active
@export var current_stat_attributes: StatAttributeSet

#endregion

#region Geometry Areas and Timers

# used to detect when actor can stop moving
@onready var interact_area: Area2D = $CollisionGeometry/InteractArea
# used to detect actor's hitbox when attacking
@onready var hit_area: Area2D = $CollisionGeometry/HitArea2D

# used to detect when actor may receive attacks or other status effects
@onready var actor_area: Area2D = $CollisionGeometry/ActorArea

@onready var attack_timer: Timer = $Timers/AttackTimer
# TODO: once placeholder art with frames is in... could code it to where when a frame starts
# enable hitbox and on end frame disable hitbox
@onready var enable_attack_timer: Timer = $Timers/EnableAttackTimer
# used to display basic attack damage text from UI
var on_attack_damage_text_updated: Callable

@onready var defense_timer: Timer = $Timers/DefenseTimer
@onready var defense_node: Node2D = $Defense

#endregion

#region Skill Placeholder

@export var skill_cast_range: float = 100.0
var lightning_placeholder: Resource = preload("res://nodes/lightning.tscn")
var active_skill: Skill
var on_skill_damage_calculation: Callable
@onready var skill_placeholder_socket: Marker2D = $Sockets/SkillPlaceholderSocket
@export var is_skill_casted: bool = false

#endregion

@export var actor_type: Constants.Actor_Type
@export var creature_type: Constants.Creature_Type
@export var energy_type: Constants.Energy_Type
@export var battle_state = Ui_Battle_State.WAITING
@export var motion_state = Active_Battle_State.NEUTRAL

@export var move_speed: float
@export var target: Node2D
var original_target: Node2D
var original_pos: Vector2
# controls if movement is allowed or not
var resume_motion: bool = true

@export var flee_fade_time: float = 1.5 # seconds

@export var skills: Array[Skill] = []

func _init():
	
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
	
	interact_area.area_entered.connect(on_other_entered)
	hit_area.area_entered.connect(on_attack_connect)
	
	
	if info_node and avatar:
		info_node.update_labels(avatar)
		
	connect_battle_signals()
	add_child(active_battle_state_machine)
	
	skill_system_component.load_skills()
	skill_system_component.skill_owner = self
	
	status_effects_component.on_start_buff.connect(on_start_buff)
	status_effects_component.on_end_buff.connect(on_end_buff)
	
	status_effects_component.on_start_debuff.connect(on_start_debuff)
	status_effects_component.on_end_debuff.connect(on_end_debuff)
	
	status_effects_component.on_second_update_buff.connect(on_second_update_buff)
	status_effects_component.on_turn_update_buff.connect(on_turn_update_buff)
	status_effects_component.on_second_update_debuff.connect(on_second_update_debuff)
	status_effects_component.on_turn_update_debuff.connect(on_turn_update_debuff)

	# TODO: this is temporary, remove once loading in data from csv or an outside data source is complete
	# hp, strength, energy, toughness, speed
	var some_stats: Array[float] = [1000, 20, 30, 15, 34]
	base_stat_attributes = StatAttributeSet.new()
	current_stat_attributes = StatAttributeSet.new()
	base_stat_attributes.load_stats(some_stats)
	current_stat_attributes.load_stats(some_stats)

var start_buff_time: float = 0.0
var start_debuff_time: float = 0.0

# buffs to test
var thorny_def = "Thorny Defense"
var thorny_def_stat_buffs = "Thorny Defense Stat Buffs"

func on_start_buff(status_effect: StatusEffect):
	print("applying buff: ", status_effect.name)
	start_buff_time = Time.get_ticks_msec()
	
	if status_effect.name == thorny_def_stat_buffs:
		print("start toughness value now: ", current_stat_attributes.toughness.value)
		print("start speed value now: ", current_stat_attributes.speed.value)
		
		var toughness_delta: float = 0
		var speed_delta: float = 0

		for modifier in status_effect.modifiers:
			match modifier.stat_category_type_target:
				Constants.STAT_TOUGHNESS:
					toughness_delta += modifier.stat_value
				Constants.STAT_SPEED:
					speed_delta += modifier.stat_value
				
	
		current_stat_attributes.toughness.value += toughness_delta
		current_stat_attributes.speed.value += speed_delta
		
		print("toughness value now: ", current_stat_attributes.toughness.value)
		print("speed value now: ", current_stat_attributes.speed.value)

func on_end_buff(status_effect: StatusEffect):
	print("buff ending: ", status_effect.name)
	print("duration: ", Time.get_ticks_msec() - start_buff_time)
	
	if status_effect.name == thorny_def:
		print("no longer have thorny defense")
	elif status_effect.name == thorny_def_stat_buffs:
		print("restoring stats back naively")
		var toughness_modifier: Modifier
		var speed_modifier: Modifier
		for modifier in status_effect.modifiers:
			if modifier.stat_category_type_target == Constants.STAT_TOUGHNESS:
				toughness_modifier = modifier
			elif modifier.stat_category_type_target == Constants.STAT_SPEED:
				speed_modifier = modifier
		
		assert(toughness_modifier != null)
		assert(speed_modifier != null)
		
		current_stat_attributes.toughness.value += -1 * toughness_modifier.stat_value
		current_stat_attributes.speed.value += -1 * speed_modifier.stat_value
		
		print("removing toughness: ", current_stat_attributes.toughness.value)
		print("removing speed: ", current_stat_attributes.speed.value)
		
		current_stat_attributes.toughness.notify_all()
		current_stat_attributes.speed.notify_all()

func on_start_debuff(status_effect: StatusEffect):
	print("applying debuff: ", status_effect.name)
	start_debuff_time = Time.get_ticks_msec()
	
func on_end_debuff(status_effect: StatusEffect):
	print("ending debuff: ", status_effect.name)
	print("duration: ", Time.get_ticks_msec() - start_debuff_time)

func on_second_update_buff(status_effect: StatusEffect):
	print("being applied over time: ", status_effect.name)
	
func on_turn_update_buff(status_effect: StatusEffect):
	print("on turn update for buff: ", status_effect.name)
	
func on_second_update_debuff(status_effect: StatusEffect):
	print("being applied over time: ", status_effect.name)
	
func on_turn_update_debuff(status_effect: StatusEffect):
	print("on turn update for debuff: ", status_effect.name)

func connect_battle_signals():
	if avatar:
		avatar.on_start_turn.connect(func(): BattleSignals.on_start_turn.emit(self))

func move_back_to_original_position(delta_time: float) -> float:
	# move back to original position
	var vel: Vector2 = move_to_target(original_pos)
	position += vel * delta_time
	var dist: float = position.distance_to(original_pos)
	return dist

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
		
	# turn on interact area to detect when an attack animation can be simulated
	#interact_area.monitoring = true
	interact_area.set_deferred("monitoring", true)
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
	#interact_area.monitoring = false
	interact_area.set_deferred("monitoring", false)

	# if not target OR the other area2D isn't an actor's collision body, don't trigger the attack state
	if !target or target.get_node("CollisionGeometry/ActorArea") != other:
		return
	
	if motion_state == Active_Battle_State.MOVING:
		print("entered attacking area: %s" % other.name)
		motion_state = Active_Battle_State.ATTACK
		# simulate attack animation delay -- timer
		enable_attack_timer.start()

func on_attack_end():
	# attack should not end as it got cancelled...
	if motion_state == Active_Battle_State.KNOCKBACK:
		return
	print("%s ending attack" % avatar.avatar_data.avatar_name)
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
			print_rich("[color=red]Unable to find actor to damage for %s[/color]" % avatar.avatar_data.avatar_name)
			BattleSignals.on_end_turn.emit(self)
			return
		
		var damage_receiver: Avatar = actor_receiving_dmg.avatar
		var damage_dealer: Avatar = avatar
		
		var dmg = damage_calculator.calculate_damage(actor_receiving_dmg, self)
		damage_receiver.avatar_data.current_stats.hp = maxi(damage_receiver.avatar_data.current_stats.hp - dmg, 0)
		damage_calculator.on_damage_received.emit(actor_receiving_dmg, self, dmg)
		
		# TODO: temporary - check if actor receiving dmg has thorny defense status effect....
		# in a streamlined approach, I would need to loop through all the buffs and debuffs
		# this actor has and call a function to compute changes in stats at this point in time
		var target_status_effects_component: StatusEffectsComponent = actor_receiving_dmg.status_effects_component
		var thorny_def: String = "Thorny Defense"
		if target_status_effects_component.has_buff(thorny_def):
			var effect: StatusEffect = target_status_effects_component.buff_tags[thorny_def]
			# assume modifier type are all flat values
			var hp_modifier: Modifier = null
			for modifier in effect.get_modifiers():
				if modifier.stat_category_type_target == Constants.STAT_HP:
					hp_modifier = modifier
					break
			
			assert(hp_modifier != null)
			print ("applying thorny defense damage of value: ", hp_modifier.stat_value)
			damage_dealer.avatar_data.current_stats.hp = maxi(damage_dealer.avatar_data.current_stats.hp - hp_modifier.stat_value, 0)
			damage_calculator.on_damage_received.emit(self, actor_receiving_dmg, hp_modifier.stat_value)
		
		print("on damage received basic attack: %s atks %s for %d dmg" % [damage_dealer.avatar_data.avatar_name, damage_receiver.avatar_data.avatar_name, dmg])
		
		# TODO: need to know what action the actor picked in order to print out the appropriate message for attack or skill
		var text = "%s attacked %s for %d damage" % [damage_dealer.avatar_data.avatar_name, damage_receiver.avatar_data.avatar_name, dmg]
		if !on_attack_damage_text_updated.is_null():
			if on_attack_damage_text_updated.call(text):
				print_rich("[color=red]on_attack_damage_text_updated has invalid function reference... ensure it is set before calling[/color]")
			
			# hack to unset function call
			on_attack_damage_text_updated = func(_text: String): return true
		
		# only interrupt motion if not defending or using a skill
		if not [Active_Battle_State.DEFEND, Active_Battle_State.SKILL].has(actor_receiving_dmg.motion_state):
			self.on_interrupt_motion(actor_receiving_dmg, Constants.Battle_State.PAUSED)
	else:
		print_rich("[color=red]Damage Calculator is null in Actor.gd[/color]")

func start_defend():
	defense_node.visible = true
	defense_timer.start()
	
func on_defend_end():
	motion_state = Active_Battle_State.NEUTRAL
	active_battle_state_machine.transition_to(Constants.Active_Battle_State.NEUTRAL)
	BattleSignals.on_end_turn.emit(self)

func begin_flee():
	if motion_state == Active_Battle_State.FLEE:
		return
		
	motion_state = Active_Battle_State.FLEE
	active_battle_state_machine.transition_to(Active_Battle_State.FLEE)

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
	#hit_area.monitoring = is_enabled
	hit_area.set_deferred("monitoring", is_enabled)

func toggle_timers(is_paused: bool):
	attack_timer.paused = is_paused
	enable_attack_timer.paused = is_paused
	defense_timer.paused = is_paused

func fadeout(t: float):
	var shader_mat = material as ShaderMaterial
	assert(is_instance_valid(shader_mat))
	shader_mat.set_shader_parameter("transparency_value", t)
	info_node.visible = false
	
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
		print("resuming actor motion for ", avatar.avatar_data.avatar_name)
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
	#interact_area.monitoring = false
	interact_area.set_deferred("monitoring", false)
	attack_timer.stop()
	
	# cancel skills that did not connect
	avatar.battle_timers.skill_timer.stop()
	Utility.disconnect_all_signal_connections(avatar.battle_timers.skill_timer.timeout)

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
	var hit_area: Area2D = get_node("CollisionGeometry/HitArea2D")
	var actor_area: Area2D = get_node("CollisionGeometry/ActorArea")
	var target_selection_area: Area2D = get_node("CollisionGeometry/TargetSelectionArea")
	
	if actor_type == Constants.Actor_Type.PARTY_MEMBER:
		interact_area.collision_layer = PLAYER_INTERACT_RANGE
		interact_area.collision_mask = ENEMY
		
		hit_area.collision_layer = PLAYER_ATTACK
		hit_area.collision_mask = ENEMY
		
		actor_area.collision_layer = PLAYER
		actor_area.collision_mask = ALL | ENEMY_INTERACT_RANGE | ENEMY_ATTACK
		
		target_selection_area.collision_layer = LAYER_8
		target_selection_area.collision_mask = LAYER_8
	elif actor_type == Constants.Actor_Type.ENEMY:
		interact_area.collision_layer = ENEMY_INTERACT_RANGE
		interact_area.collision_mask = PLAYER
		
		hit_area.collision_layer = ENEMY_ATTACK
		hit_area.collision_mask = PLAYER
		
		actor_area.collision_layer = ENEMY
		actor_area.collision_mask = ALL | PLAYER_INTERACT_RANGE | PLAYER_ATTACK
		
		target_selection_area.collision_layer = LAYER_8
		target_selection_area.collision_mask = LAYER_8

func enable():
	set_process(true)
	set_physics_process(true)
	active_battle_state_machine.enable()
	status_effects_component.enable()

func disable():
	set_process(false)
	set_physics_process(false)
	active_battle_state_machine.disable()
	status_effects_component.disable()

func construct(avatar_data: AvatarData):
	# replace default graphics with graphics from avatar_data
	var preview_resource: PackedScene = avatar_data.avatar_preview
	var body: Node2D = $ArtRoot/body
	body.queue_free()
	
	# wait 1 frame to delete body from ArtRoot as it takes the end of frame for queue_free() to delete a node
	await Engine.get_main_loop().process_frame

	var new_body: Node2D = preview_resource.instantiate()
	$ArtRoot.add_child(new_body)
	
	# create new shader per instance as godot by default modifies a single shader instance for all packed scene nodes that depend on it
	# tradeoff: costs more resources as this is creating copies of the shader
	# https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/shading_language.html#per-instance-uniforms
	material = ShaderMaterial.new()
	material.shader = load("res://shaders/transparent_fade.gdshader")
	
	# apply transparent shader effect on all body parts
	set_descendant_material_as_root_material()
