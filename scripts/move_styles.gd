extends Node2D

# timer based
#func _ready():
	#var timer = Timer.new()
	#timer.wait_time = 0.1  # Move every 0.1 seconds
	#timer.one_shot = false
	#add_child(timer)
	#timer.start()
	#timer.timeout.connect(_on_timer_timeout)
#
#func _on_timer_timeout():
	#position += Vector2(10, 0)  # Move 10 pixels to the right

# tween based
#func _ready():
	#var tween = get_tree().create_tween()	
	## Move the object to position (200, 200) in 1 second
	#tween.tween_property(self, "position", Vector2(200, 200), 1.0)
	#tween.play()

# await example	
#func _process(float) -> void:
	#print("waiting: %d" % Time.get_ticks_msec())
	#set_process(false)
	#await get_tree().create_timer(10).timeout
	#set_process(true)
	#print("wait after: %d" % Time.get_ticks_msec())


# moving using lerp and await.... can it handle collision detection?	
#func _ready():
	#await move_to(Vector2(300, 300), 1.0)
#
#func move_to(target_position: Vector2, duration: float):
	#var start_position = position
	#var elapsed_time = 0.0
	#while elapsed_time < duration:
		#position = start_position.lerp(target_position, elapsed_time / duration)
		#print("go")
		#var ss = Time.get_ticks_msec()
		#await get_tree().create_timer(0.016).timeout  # ~60 FPS
		#print("move")
		#var se = Time.get_ticks_msec()
		#var dt: float = float(se - ss) / 1000.0
		#elapsed_time += dt
	#position = target_position
