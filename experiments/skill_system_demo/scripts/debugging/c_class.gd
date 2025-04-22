extends BClass
class_name CClass

func on_start(tag: String, expiry: int):
	print("In C Class on start %s - %d" % [tag, expiry])

func on_end(tag: String, expiry: int):
	print("In C Class on end %s - %d" % [tag, expiry])

func _init(a: AClass):
	self.name = "CClass"
	super._init(a)
	
