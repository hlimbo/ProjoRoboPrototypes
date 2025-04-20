extends Resource
class_name SubjectResource

# This list will receive a message from this class
# when it does a side-effect
var observers: Array[IObserverResource] = [] 

func add_listener(observer: IObserverResource):
	observers.append(observer)

# returns True if removed; False otherwise
func remove_listener(observer: IObserverResource) -> bool:
	var index: int = observers.find(observer)
	if index != -1:
		observers.remove_at(index)
		
	return index != -1

# notifies all observers of a new change this interface invoked
func notify_all():
	for observer in observers:
		observer.notify(self)
