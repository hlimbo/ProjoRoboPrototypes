extends ColorRect
class_name TransitionFade

@onready var exit_timer: Timer = $Timer
@export var transition_duration: float = 2

signal on_finish_tween()

func start_transition():
	self.visible = true
	# set to high z-index to prevent clicks from game objects behind from registering
	self.z_index = 999
	var tween: Tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "color:a", 1, transition_duration).from(0)
	
	tween.finished.connect(tween_finished)
	exit_timer.timeout.connect(func(): on_finish_tween.emit())
	
func tween_finished():
	exit_timer.start()
