extends PathFollow2D
class_name Avatar

enum Avatar_Type {
	PARTY_MEMBER,
	ENEMY
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

## Timers
var defense_timer: Timer

signal on_start_order_step(avatar: Avatar, defense_timer: Timer)
signal on_start_exe_step(body: Node2D)

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

func _ready() -> void:
	_curr_speed = move_speed
	sprite_2d.texture = texture
	area_2d.body_entered.connect(on_area_entered)
	area_2d.body_exited.connect(on_area_exited)

func _physics_process(delta: float) -> void:
	path_follow_2d.progress_ratio += delta * _curr_speed

func on_area_entered(body: Node2D) -> void:
	on_start_order_step.emit(self)

func on_area_exited(body: Node2D) -> void:
	on_start_exe_step.emit(body)
