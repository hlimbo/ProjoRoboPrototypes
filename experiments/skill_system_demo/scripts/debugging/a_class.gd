extends RefCounted
class_name AClass

var timer: Timer
var counter: int = 0
var tags: Dictionary = {}

var b: BClass
var c: CClass
var d: DClass


signal on_start(new_tag: String, expiry: int)
signal on_end(new_tag: String, expiry: int)

# It seems to be a godot thing where it does not emit
# the signal if the classes created are inheriting from RefCounted
# Signals emit when classes are inheriting from Node
func construct_dependencies():
	b = BClass.new(self)
	c = CClass.new(self)
	d = DClass.new(self)

func _init():
	timer = Timer.new()
	timer.one_shot = false
	timer.wait_time = 1
	timer.timeout.connect(on_second_passed)
	self.construct_dependencies()

# this enables the timer to be activated as long as its in a scene tree
func add_timer_to_node(node: Node):
	node.add_child(timer)

func add_tag(tag: String, expiry: int):
	var tag_count: int = len(tags)
	tags[tag] = expiry
	on_start.emit(tag, expiry)

	if tag_count == 0:
		timer.start()

func remove_tag(tag: String):
	assert(tag in tags)
	
	var expiry: int = tags[tag]
	tags.erase(tag)
	on_end.emit(tag, expiry)
	
	if len(tags) == 0:
		timer.stop()
		counter = 0

func on_second_passed():
	print("time passed: ", counter)
	
	var expired_tags: PackedStringArray = []
	for tag in tags:
		var expiry: int = tags[tag]
		if counter >= expiry:
			expired_tags.append(tag)
	
	for expired_tag in expired_tags:
		remove_tag(expired_tag)
	
	counter += 1
	
func print_connections_count():
	var start_connections = self.on_start.get_connections()
	var end_connections = self.on_end.get_connections()
	print("start count: ", len(start_connections))
	print("end count: ", len(end_connections))
