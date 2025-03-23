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
@export var max_damage: int = 999

#region Dependencies
@export var target: Node2D
@export var original_position: Vector2
@export var vfx: AnimationPlayer
@export var starburst: Node2D
#endregion

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

func on_attack_area_entered(other_area: Area2D):
	if other_area.is_in_group("enemy"):
		print("enemy hit")
		if is_instance_valid(other_area.get_parent()) and other_area.get_parent() is PunchingBag:
			# simulate damage
			var damage_value: int = randi_range(0, max_damage)
			starburst.rotation_degrees = randf_range(40, 80)
			
			var anim: Animation = vfx.get_animation("starburst_vfx")
			
			# modify the last key frame's scale to be proportional to the amount of damage dealt
			var value = find_track_by_name(anim, "white_starburst:scale", 1)
			var white_starburst_scale = value as Vector2
			value = find_track_by_name(anim, "black_starburst:scale", 1)
			var black_starburst_scale = value as Vector2
			
			var original_scale1 = Vector2(white_starburst_scale.x, white_starburst_scale.y)
			var original_scale2 = Vector2(black_starburst_scale.x, black_starburst_scale.y)
			
			var ratio: float = minf(0.5 + (float(damage_value) / float(max_damage)), 1.0)
			white_starburst_scale.x = white_starburst_scale.x * ratio
			white_starburst_scale.y = white_starburst_scale.y * ratio
			black_starburst_scale.x = black_starburst_scale.x * ratio
			black_starburst_scale.y = black_starburst_scale.y * ratio
			
			set_track_key_value_by_name(anim, "white_starburst:scale", 1, white_starburst_scale)
			set_track_key_value_by_name(anim, "black_starburst:scale", 1, black_starburst_scale)
			
			vfx.play("starburst_vfx")
			
			# revert scales back to original sizes
			vfx.animation_finished.connect(func(anim_name: StringName):
				print("%s finished" % anim_name)
				set_track_key_value_by_name(anim, "white_starburst:scale", 1, original_scale1)
				set_track_key_value_by_name(anim, "black_starburst:scale", 1, original_scale2)
			)
		
			# Animation Principle: add Anticipation for player to attack
			var attack_delay_timer: SceneTreeTimer = get_tree().create_timer(0.25)
			attack_delay_timer.timeout.connect(func():
				var punching_bag = other_area.get_parent() as PunchingBag
				punching_bag.receive_damage(damage_value, max_damage)
				
				# here you would add something to transition to move state once attack animation completes
				current_state = EXPR_STATE.MOVING_BACK
			)
			
			
func start_attack():
	if current_state == EXPR_STATE.NEUTRAL:
		current_state = EXPR_STATE.MOVING_TO_TARGET


# since godot doesn't have a function to lookup animation tracks by string name
# one must be written up
func find_track_by_name(anim: Animation, track_name: String, key_index: int) -> Variant:
	assert(key_index >= 0)
	
	var track_index: int = anim.find_track(NodePath(track_name), Animation.TrackType.TYPE_VALUE)
	if track_index == -1:
		print_rich("[color=yellow]Unable to find track named %s[/color]", track_name)
	else:
		var value = anim.track_get_key_value(track_index, key_index)
		if value == null:
			print_rich("[color=yellow]Track %d at key %d has invalid value[/color]" % [track_index, key_index])
			
		return value
		
	return null
	
func set_track_key_value_by_name(anim: Animation, track_name: String, key_index: int, value: Variant):
	assert(key_index >= 0)
	
	var track_index: int = anim.find_track(NodePath(track_name), Animation.TrackType.TYPE_VALUE)
	if track_index == -1:
		print_rich("[color=yellow]Unable to find track named %s[/color]", track_name)
	else:
		anim.track_set_key_value(track_index, key_index, value)
		
func print_anim_tracks_and_keys(anim: Animation):
	print("track count: ",anim.get_track_count())
	for i in range(anim.get_track_count()):
		var track_type = anim.track_get_type(i)
		var track_path: NodePath = anim.track_get_path(i)
		print("track type: ", track_type)
		print("track_path: ", track_path)
		for j in range(anim.track_get_key_count(i)):
			var v2 = anim.track_get_key_value(i, j)
			print("value at key %d is %s" % [j, v2])
