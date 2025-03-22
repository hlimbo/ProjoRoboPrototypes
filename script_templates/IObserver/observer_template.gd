# meta-name: Observer Pattern
# meta-description: Used to communicate between 2 different systems (e.g. UI and Gameplay)
# meta-default: true
# meta-space-indent: 4
extends IObserver

# used to receive communication from the subject that something changed
# Override this function to handle specific logic to pass down data incoming from a subject
# Common use cases here include a UI view component that needs to display updated information being computed
func notify(subject: Subject):
	pass
