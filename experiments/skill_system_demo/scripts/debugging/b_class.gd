extends RefCounted
class_name BClass

var name: String = "BClass"
var a_ref: AClass

func on_start(tag: String, expiry: int):
	print("In B Class on start %s - %d" % [tag, expiry])

func on_end(tag: String, expiry: int):
	print("In B Class on end %s - %d" % [tag, expiry])

	
func _init(a: AClass):
	print("initing go! ", self.name)
	a_ref = a
	# CONNECT_REFERENCE_COUNTED ensures the class that has the function
	# will be disconnected from the below signals
	# if we don't set this flag, the connection between the signals and
	# the functions belonging to this class's instance will persist
	# introducing a Signal Leak!
	a_ref.on_start.connect(on_start, ConnectFlags.CONNECT_REFERENCE_COUNTED)
	a_ref.on_end.connect(on_end, ConnectFlags.CONNECT_REFERENCE_COUNTED)
