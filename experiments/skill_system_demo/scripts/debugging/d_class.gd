extends BClass
class_name DClass

func on_start(tag: String, expiry: int):
	print("In D Class on start %s - %d" % [tag, expiry])

func on_end(tag: String, expiry: int):
	print("In D Class on end %s - %d" % [tag, expiry])

func _init(a: AClass):
	self.name = "DClass"
	super._init(a)
