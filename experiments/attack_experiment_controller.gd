extends Node2D
class_name AttackExperimentController

enum EXPR_STATE {
	NEUTRAL,
	MOVING_TO_TARGET,
	MOVING_BACK,
	ATTACKING
}

@onready var attack_range: Area2D = $AttackRange
@onready var attack_area: Area2D = $AttackArea

@export var current_state: EXPR_STATE = EXPR_STATE.NEUTRAL
@export var move_speed: float = 1000.0

@export var target: Node2D
@export var original_position: Vector2

# Note: drawing uses this node's canvas item's coordinate system
# so it will be relative to this node's transform as opposed to the world's transform...
# this means Vector2(0,0) is this canvas item's origin relative to itself and not relative to world transform
func draw_debug_arrows():
	var line_width: float = 1
	var line_height: float = 100
	# relative to this canvas item's origin
	var from: Vector2 = Vector2(0,0)
	var to_x: Vector2 = from + transform.x * line_height
	var to_y: Vector2 = from + transform.y * line_height
	draw_line(from, to_x, Color.RED, line_width)
	draw_line(from, to_y, Color.GREEN, line_width)

func move(delta_time: float):
	# these are basis vectors that represent the axis that this node2d orients itself
	# by default it is aligned to the global x and y axes but can be rotated, scaled and skewed
	# will treat this as the forward vector
	#print(self.transform.x)
	#print(self.transform.y)
	
	var move_vel: Vector2 = self.transform.x * move_speed * delta_time
	self.position = self.position + move_vel

func _ready():
	attack_range.area_entered.connect(on_area_entered)
	attack_area.area_entered.connect(on_attack_area_entered)
	original_position = self.position

func _physics_process(delta: float):
	if current_state == EXPR_STATE.MOVING_TO_TARGET:
		if is_instance_valid(target):
			look_at(target.position)
			move(delta)
	elif current_state == EXPR_STATE.MOVING_BACK:
		look_at(original_position)
		move(delta)
		
		var dist_tol: float = 0.01
		var distance = position.distance_to(original_position)
		if distance <= dist_tol:
			current_state = EXPR_STATE.NEUTRAL

func _draw():
	draw_debug_arrows()

func on_area_entered(other_area: Area2D):
	if other_area.is_in_group("enemy"):
		current_state = EXPR_STATE.ATTACKING
		attack_area.visible = true

func on_attack_area_entered(other_area: Area2D):
	if other_area.is_in_group("enemy"):
		print("enemy hit")
		if is_instance_valid(other_area.get_parent()) and other_area.get_parent() is PunchingBag:
			var punching_bag = other_area.get_parent() as PunchingBag
			punching_bag.receive_damage()
			
			# here you would add something to transition to move state once attack animation completes
			current_state = EXPR_STATE.MOVING_BACK
			
func start_attack():
	if current_state == EXPR_STATE.NEUTRAL:
		current_state = EXPR_STATE.MOVING_TO_TARGET
