extends Node2D
# controller class that will do all the actions!
# will break down into smaller things as needed
# strat - top down approach (code high level things)
# work backwards from what kind of gameplay to achieve
class_name Actor

@onready var damage_calculator: IDamageCalculator = BattleSceneManager.damage_calculator
@onready var info_node: InfoDisplay = $InfoNode

@export var move_speed: float
@export var target: Node2D
@export var battle_state = Constants.Battle_State.WAITING
@export var motion_state = Constants.Motion_State.NEUTRAL
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

var delay_timer: Timer = Timer.new()
var can_start_movement: bool = false

func _ready():
	original_pos = position
	
	interact_area.area_entered.connect(on_other_entered)
	attack_timer.timeout.connect(on_attack_end)
	enable_attack_timer.timeout.connect(on_enable_attack_hitbox)
	hit_area.area_entered.connect(on_attack_connect)
	
	# hardcode testing
	if avatar:
		avatar.generate_random_stats()
	
	if info_node and avatar:
		info_node.update_labels(avatar)
	
	# info_node.visible = enable_debug_menu
	# Temp code to capture gif
	delay_timer.autostart = false
	delay_timer.one_shot = true
	delay_timer.wait_time = 3
	delay_timer.timeout.connect(func(): can_start_movement = true)
	add_child(delay_timer)
	delay_timer.start()

func _process(delta_time: float):
	if !can_start_movement:
		return
	
	if battle_state == Constants.Battle_State.PENDING_MOVE:
		var vel: Vector2 = move_to_target(target.position)
		position += vel * delta_time
	elif motion_state == Constants.Motion_State.MOVING:
		# move back to original position
		var vel: Vector2 = move_to_target(original_pos)
		position += vel * delta_time
		
		# if close enough transition to neutral state -> stop moving
		var dist = position.distance_to(original_pos)
		if dist <= 100:
			motion_state = Constants.Motion_State.NEUTRAL


func move_to_target(target_pos: Vector2) -> Vector2:
	var dir = (target_pos - position).normalized()
	velocity = Vector2(dir.x, dir.y) * move_speed
	return velocity

# assume this other is always an enemy.. need to add a tagging system later on to determine what is being hit (like how unity does it)
func on_other_entered(other: Area2D):
	print("entered attacking area")
	motion_state = Constants.Motion_State.NEUTRAL
	
	if battle_state == Constants.Battle_State.PENDING_MOVE:
		battle_state = Constants.Battle_State.EXECUTING_MOVE
		# simulate attack animation delay -- timer
		enable_attack_timer.start()
	else: # wait if attack already happened
		battle_state = Constants.Battle_State.WAITING
	
func on_attack_end():
	print("ending attack")
	motion_state = Constants.Motion_State.MOVING
	battle_state = Constants.Battle_State.WAITING

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
