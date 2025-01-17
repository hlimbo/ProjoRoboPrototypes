extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var current_state: String

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var curr_facing_direction: float = 1
var direction: float = 0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		curr_facing_direction = direction
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	handle_animation()
	handle_animation_sprite(direction)

# My implementation
func handle_animation():
	#alternatively, CharacterBody2D node has a built in function called
	# is_on_floor() that checks if you are grounded based on the 
	# computations of built in function move_and_slide()
	if direction == 0 and velocity.y == 0:
		animated_sprite.play("idle")
	elif velocity.y != 0:
		animated_sprite.play("jump")
	elif velocity.x != 0:
		animated_sprite.play("run")
		
	# check facing direction
	animated_sprite.flip_h = curr_facing_direction < 0


func update_animation_player(state):
	var is_player_facing_left = animated_sprite.flip_h
	if state == "idle" and !is_player_facing_left:
		animation_player.play("right_sword_idle")
	elif state == "idle" and is_player_facing_left:
		animation_player.play("left_sword_idle")
	
	elif state == "run" and !is_player_facing_left:
		animation_player.play("right_sword_run")
	elif state == "run" and is_player_facing_left:
		animation_player.play("left_sword_run")

	elif state == "jump" and !is_player_facing_left:
		animation_player.play("right_sword_jump")
	elif state == "jump" and is_player_facing_left:
		animation_player.play("left_sword_jump")
	
	
func choose_state():
	var new_state: String
	# built in godot function for character
	if is_on_floor():
		if velocity:
			new_state = "run"
		else:
			new_state = "idle"
	else:
		new_state = "jump"
	
	return new_state

func handle_animation_sprite(direction):
	if current_state != choose_state():
		current_state = choose_state()
		animated_sprite.play(current_state)
		update_animation_player(current_state)
