extends Node

@export var move_speed: float = 5

@onready var path_follow_2d: PathFollow2D = $"."
@onready var area_2d: Area2D = $Sprite2D/Area2D

signal on_enter_order_step(body: Node2D)
signal on_enter_exe_step(body: Node2D)
signal on_exit_order_step(body: Node2D)
signal on_exit_exe_step(body: Node2D)

func _ready() -> void:
	area_2d.body_entered.connect(on_area_entered)
	area_2d.body_exited.connect(on_area_exited)

func _process(delta: float) -> void:
	path_follow_2d.progress_ratio += delta * move_speed

func on_area_entered(body: Node2D) -> void:
	if body.name == "Order":
		on_enter_order_step.emit(body)
	elif body.name == "Exe":
		on_enter_exe_step.emit(body)

func on_area_exited(body: Node2D) -> void:
	if body.name == "Order":
		on_exit_order_step.emit(body)
	elif body.name == "Exe":
		on_exit_exe_step.emit(body)
