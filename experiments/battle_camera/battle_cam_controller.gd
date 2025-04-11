extends Node2D
class_name BattleCamController

# Interpolation Methods used
# to follow a target
enum MotionMethod {
	Linear, # LERP
	Smoothstep, # Hermite Interpolation
	Quadratic, # X^2
}

# describes if this class can
# follow a single target or multiple targets in view 
enum FocusMode {
	Single,
	Multi
}

# number of seconds it takes before camera
# starts following target
@export var follow_delay: float

# describes the distance this class follows
@export var follow_offset: Vector2
