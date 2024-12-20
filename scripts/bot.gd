extends Node2D

@export var stats: HelloWoi

func _ready():
	# uses implicit, duck-typed interface for health-compatible resources
	if stats:
		print("stats: ")
		stats.print_all_properties()
