extends PathFollow2D
class_name Avatar

enum Avatar_Type {
	PARTY_MEMBER,
	ENEMY
}

enum Battle_State {
	WAITING,
	MOVE_SELECTION,
	PENDING_MOVE,
	EXECUTING_MOVE,
	MOVE_CANCELLED,
	# used when receiving damage
	PAUSED,
	KNOCKBACK
}

@export var move_speed: float = 0.1
var _curr_speed: float

@export var texture: Texture2D

@onready var path_follow_2d: PathFollow2D = $"."
@onready var area_2d: Area2D = $Sprite2D/Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D

var initial_stats: BaseStats
var curr_stats: BaseStats
var avatar_type: Avatar_Type
var is_alive: bool
# controls whether or not movement along timeline continues on
var resume_motion: bool = true

## Timers
var defense_timer: Timer
# TODO: move to a skill manager class
var skill_timer: Timer
var resume_delay_timer: Timer

signal on_start_order_step(avatar: Avatar)
signal on_start_exe_step(body: Node2D)

signal on_avatar_flee()

func _init() -> void:
	initial_stats = BaseStats.new()
	curr_stats = BaseStats.new()
	is_alive = true
	
	defense_timer = Timer.new()
	# godot engine will generate a unique name as nodes that are
	# siblings of each other must have unique names
	defense_timer.name = "DefenseTimer"
	defense_timer.autostart = false
	defense_timer.one_shot = true
	defense_timer.wait_time = 1 # seconds
	defense_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	
	skill_timer = Timer.new()
	skill_timer.name = "SkillTimer"
	skill_timer.autostart = false
	skill_timer.one_shot = true
	skill_timer.wait_time = 3 # seconds
	skill_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS

	resume_delay_timer = Timer.new()
	resume_delay_timer.name = "resume_delay_timer"
	resume_delay_timer.autostart = false
	resume_delay_timer.one_shot = true
	resume_delay_timer.wait_time = 2 # seconds
	resume_delay_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS


func _ready() -> void:
	_curr_speed = move_speed
	sprite_2d.texture = texture
	area_2d.body_entered.connect(on_area_entered)
	area_2d.body_exited.connect(on_area_exited)

func _physics_process(delta: float) -> void:
	path_follow_2d.progress_ratio += delta * _curr_speed * float(resume_motion)

func on_area_entered(body: Node2D) -> void:
	on_start_order_step.emit(self)

func on_area_exited(body: Node2D) -> void:
	on_start_exe_step.emit(body)
	
func on_test_press(avatar: Avatar):
	print("test press avatar param: %s" % avatar.name)
	print("test press self param: %s" % self.name)
