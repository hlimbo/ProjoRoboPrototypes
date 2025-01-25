extends Node2D
# controller class that will do all the actions!
# will break down into smaller things as needed
# strat - top down approach (code high level things)
# work backwards from what kind of gameplay to achieve
class_name Actor

@export var move_speed: float
@export var target: Node2D
@export var battle_state = Constants.Battle_State.WAITING
@export var motion_state = Constants.Motion_State.NEUTRAL

@export_group("Debug Menu")
@export var enable_debug_menu: bool

var velocity: Vector2
var original_pos: Vector2

@onready var player_interact_area: Area2D = $PlayerArea2D
@onready var hit_area: Area2D = $HitArea2D
@onready var hit_shape: CollisionShape2D = $HitArea2D/CollisionShape2D

@onready var attack_timer: Timer = $AttackTimer
# TODO: once placeholder art with frames is in... could code it to where when a frame starts
# enable hitbox and on end frame disable hitbox
@onready var enable_attack_timer: Timer = $EnableAttackTimer


### Debug UI ###
@onready var info_node: InfoDisplay = $InfoNode


func _ready():
	original_pos = position
	
	player_interact_area.area_entered.connect(on_other_entered)
	attack_timer.timeout.connect(on_attack_end)
	enable_attack_timer.timeout.connect(on_enable_attack_hitbox)
	hit_area.area_entered.connect(on_attack_connect)
	
	# info_node.visible = enable_debug_menu

func _process(delta_time: float):
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

	# disable at end of frame as per Godot Docs recommendation
	print("disabling attack at end of frame")
	hit_shape.set_deferred("disabled", true)
