extends Button

var a: AClass

func _init():
	a = AClass.new()
	# Timers need to be added to a node belonging to a scene tree
	# otherwise they will not be able to be started
	a.add_timer_to_node(self)
	
func _ready():
	self.pressed.connect(on_click)
	
func on_click():
	a.add_tag("jonny", 1)
	a.add_tag("test", 3)
	a.print_connections_count()
