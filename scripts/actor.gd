extends Node2D
# controller class that will do all the actions!
# will break down into smaller things as needed
# strat - top down approach (code high level things)
# work backwards from what kind of gameplay to achieve
class_name Actor

# Type Aliases through singleton script constants
const Ui_Battle_State = Constants.Battle_State
const Active_Battle_State = Constants.Active_Battle_State

@onready var damage_calculator: IDamageCalculator = BattleSceneManager.damage_calculator
@onready var info_node: InfoDisplay = $InfoNode

@export var move_speed: float
@export var target: Node2D
var original_target: Node2D
@export var battle_state = Ui_Battle_State.WAITING
@export var motion_state = Active_Battle_State.NEUTRAL
# TODO - move curr_stats and initial_stats from avatar to here
@export var avatar: Avatar


@export_group("Debug Menu")
@export var enable_debug_menu: bool

var velocity: Vector2
var original_pos: Vector2

# used to detect when actor can stop moving
@onready var interact_area: Area2D = $CollisionGeometry/InteractArea
# used to detect actor's hitbox when attacking
@onready var hit_area: Area2D = $CollisionGeometry/HitArea2D
@onready var hit_shape: CollisionShape2D = $CollisionGeometry/HitArea2D/CollisionShape2D

# used to detect when actor may receive attacks or other status effects
@onready var actor_area: Area2D = $CollisionGeometry/ActorArea

@onready var attack_timer: Timer = $Timers/AttackTimer
# TODO: once placeholder art with frames is in... could code it to where when a frame starts
# enable hitbox and on end frame disable hitbox
@onready var enable_attack_timer: Timer = $Timers/EnableAttackTimer

@onready var defense_timer: Timer = $Timers/DefenseTimer

@onready var defense_node: Node2D = $Defense

var flee_time: float = 0.0
@export var flee_fade_time: float = 3.0

#region Commands
var attack_cmd: AttackCommand
var defend_cmd: DefendCommand
var pick_skill_cmd: PickSkillCommand
var flee_cmd: FleeCommand
#endregion

func _init():
	attack_cmd = AttackCommand.new()
	defend_cmd = DefendCommand.new()
	pick_skill_cmd = PickSkillCommand.new()
	flee_cmd = FleeCommand.new()

func _ready():
	original_pos = position
	original_target = target
	
	interact_area.area_entered.connect(on_other_entered)
	attack_timer.timeout.connect(on_attack_end)
	enable_attack_timer.timeout.connect(on_enable_attack_hitbox)
	defense_timer.timeout.connect(on_defend_end)
	hit_area.area_entered.connect(on_attack_connect)
	
	# hardcode testing
	if avatar:
		avatar.generate_random_stats()
	
	if info_node and avatar:
		info_node.update_labels(avatar)

func _process(delta_time: float):
	# player controls
	if (name == "yellow_mob"):
		if (Input.is_action_pressed("attack")):
			attack_cmd.execute(self)
		elif (Input.is_action_pressed("defend")):
			defend_cmd.execute(self)
		elif (Input.is_action_pressed("flee")):
			flee_cmd.execute(self)
	# enemy controls
	elif (name == "BaseBodyE"):
		if (Input.is_action_pressed("attack2")):
			attack_cmd.execute(self)
		elif (Input.is_action_pressed("defend2")):
			defend_cmd.execute(self)


	if motion_state == Active_Battle_State.MOVING:
		if target:
			var vel: Vector2 = move_to_target(target.position)
			position += vel * delta_time
		else:
			# move back to original position
			var vel: Vector2 = move_to_target(original_pos)
			position += vel * delta_time
		
			# if close enough transition to neutral state -> stop moving
			var dist = position.distance_to(original_pos)
			if dist <= 100:
				motion_state = Active_Battle_State.NEUTRAL
	elif motion_state == Active_Battle_State.FLEE:
		flee_time = clampf(flee_time + delta_time, flee_time, flee_fade_time)
		(material as ShaderMaterial).set_shader_parameter("transparency_value", flee_fade_time - flee_time)

func start_motion():
	# if already moving don't trigger it again
	if motion_state == Active_Battle_State.MOVING:
		return
	
	motion_state = Active_Battle_State.MOVING

func move_to_target(target_pos: Vector2) -> Vector2:
	var dir = (target_pos - position).normalized()
	velocity = Vector2(dir.x, dir.y) * move_speed
	return velocity

# assume this other is always an enemy.. need to add a tagging system later on to determine what is being hit (like how unity does it)
func on_other_entered(other: Area2D):
	# don't trigger this overlap if not moving previously
	# prevent double attacks
	if motion_state != Active_Battle_State.MOVING:
		return
	
	print("entered attacking area: %s" % other.name)
	motion_state = Active_Battle_State.ATTACK
	# simulate attack animation delay -- timer
	enable_attack_timer.start()
	
func on_attack_end():
	print("ending attack")
	motion_state = Active_Battle_State.MOVING
	target = null

# simulate enabling hit box at end of the frame
func on_enable_attack_hitbox():
	print("enabling attack at end of frame")
	hit_shape.set_deferred("disabled", false)
	
	# simulate attack animation
	attack_timer.start()

func on_attack_connect(area: Area2D):
	print("hit %s" % area.name)
	
	# apply damage calculations
	if damage_calculator:
		# go up the node tree for area to find the Actor... assume root node .. unsafe code
		var actor_receiving_dmg: Actor = area.get_node("../..") as Actor
		
		if actor_receiving_dmg == null:
			print_rich("[color=red]Unable to find actor to damage...[/color]")
			return
		
		var damage_receiver: Avatar = actor_receiving_dmg.avatar
		var damage_dealer: Avatar = avatar
		
		var dmg = damage_calculator.calculate_damage(damage_receiver, damage_dealer)
		damage_receiver.curr_stats.hp = maxi(damage_receiver.curr_stats.hp - dmg, 0)
		damage_calculator.on_damage_received.emit(damage_receiver, damage_dealer)
		
		
	# disable at end of frame as per Godot Docs recommendation
	print("disabling attack at end of frame")
	hit_shape.set_deferred("disabled", true)

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

func begin_flee():
	if motion_state == Active_Battle_State.FLEE:
		return
		
	flee_time = 0.0
	motion_state = Active_Battle_State.FLEE
