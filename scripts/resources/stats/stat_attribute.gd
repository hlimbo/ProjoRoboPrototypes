# A wrapper around a float value
# that represents a stat value in game
# It can be observed through signals
extends BaseResource
class_name StatAttribute

var subject: Subject
@export var value: float = 0.0

func _init():
	subject = Subject.new()
	
func add_listener(observer: IObserver):
	subject.add(observer)
	
func remove_listener(observer: IObserver):
	subject.remove(observer)

func notify_all():
	subject.notify_all()
