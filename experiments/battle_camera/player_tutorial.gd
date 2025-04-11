extends Node2D
class_name PlayerTutorial

const MAX_SPEED = 400.0
enum Direction { TOP, RIGHT, DOWN, LEFT }

signal move

var direction: Vector2
var speed: float = 0.0
var velocity: Vector2


func _ready():
	self.set_physics_process(true)
	

func _physics_process(delta: float):
	var is_moving = Input.is_action_pressed("left") or Input.is_action_pressed("right") or Input.is_action_pressed("up") or Input.is_action_pressed("down")
		
	
	if is_moving:
		speed = MAX_SPEED
		
		if Input.is_action_pressed("right"):
			turn_towards(Direction.RIGHT)
		elif Input.is_action_pressed("left"):
			turn_towards(Direction.LEFT)
		elif Input.is_action_pressed("up"):
			turn_towards(Direction.TOP)
		elif Input.is_action_pressed("down"):
			turn_towards(Direction.DOWN)
	else:
		speed = 0
	
	velocity = speed * direction * delta
	self.position += velocity
	if is_moving:
		move.emit()

func turn_towards(_direction: Direction):
	if _direction == Direction.TOP:
		direction = Vector2(0, -1)
	elif _direction == Direction.DOWN:
		direction = Vector2(0, 1)
	elif _direction == Direction.LEFT:
		direction = Vector2(-1, 0)
	elif _direction == Direction.RIGHT:
		direction = Vector2(1, 0)
