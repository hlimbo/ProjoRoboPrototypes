extends Node
class_name IObserverResource

# used to receive communication from the subject that something changed
# Override this function to handle specific logic to pass down data incoming from a subject
# Common use cases here include a UI view component that needs to display updated information being computed
func notify(subject: SubjectResource):
	pass
