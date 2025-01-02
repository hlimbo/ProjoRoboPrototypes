extends PathFollow2D
class_name Avatar

@export var move_speed: float = 0.1
var _curr_speed: float

@export var texture: Texture2D

@onready var path_follow_2d: PathFollow2D = $"."
@onready var area_2d: Area2D = $Sprite2D/Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D

signal on_start_order_step(body: Node2D)
signal on_start_exe_step(body: Node2D)

func _ready() -> void:
	_curr_speed = move_speed
	sprite_2d.texture = texture
	area_2d.body_entered.connect(on_area_entered)
	area_2d.body_exited.connect(on_area_exited)

func _physics_process(delta: float) -> void:
	path_follow_2d.progress_ratio += delta * _curr_speed

func on_area_entered(body: Node2D) -> void:
	on_start_order_step.emit(body)

func on_area_exited(body: Node2D) -> void:
	on_start_exe_step.emit(body)
