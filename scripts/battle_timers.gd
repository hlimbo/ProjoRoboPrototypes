extends Node
class_name BattleTimers

@onready var defense_timer: Timer = $DefenseTimer
@onready var resume_delay_timer: Timer = $ResumeDelayTimer
@onready var skill_timer: Timer = $SkillTimer
@onready var flee_timer: Timer = $FleeTimer

func _exit_tree() -> void:
	# timers do not eventually inherit from the RefCounted class in godot
	# therefore, freeing them here prevents memory leaks
	defense_timer.queue_free()
	resume_delay_timer.queue_free()
	skill_timer.queue_free()
	flee_timer.queue_free()
	
func toggle_timers(is_paused: bool):
	defense_timer.paused = is_paused
	#resume_delay_timer.paused = is_paused
	skill_timer.paused = is_paused
	flee_timer.paused = is_paused
