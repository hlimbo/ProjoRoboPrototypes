extends Node
class_name Subject

# This list will receive a message from this class
# when it does a side-effect
@export var observers: Array[IObserver] = [] 

func add(observer: IObserver):
	observers.append(observer)

# returns True if removed; False otherwise
func remove(observer: IObserver) -> bool:
	var index: int = observers.find(observer)
	if index != -1:
		observers.remove_at(index)
		
	return index != -1

# notifies all observers of a new change this interface invoked
func notify_all():
	for observer in observers:
		observer.notify(self)
