# Reference: https://gameprogrammingpatterns.com/state.html
extends RefCounted
class_name IState

# gets called when it transitions to this state for the first time
func on_enter():
	pass
	#print_rich("[color=yellow]Inherit from this base class IState to derive on_enter()[/color]")

func on_physics_enter():
	pass
	#print_rich("[color=yellow]Inherit from this base class IState to derive on_physics_enter()[/color]")

# gets called when an input event occurs
func on_input(event: InputEvent):
	pass
	#print_rich("[color=yellow]Inherit from this base class IState to derive on_input()[/color]")

func on_process(delta: float):
	pass
	#print_rich("[color=yellow]Inherit from this base class IState to derive on_process()[/color]")

func on_physics_process(delta: float):
	pass
	#print_rich("[color=yellow]Inherit from this base class IState to derive on_physics_process()[/color]")

# gets called when it transitions out of this state
func on_exit():
	pass
	#print_rich("[color=yellow]Inherit from this base class IState to derive on_exit()[/color]")

func on_physics_exit():
	pass
	#print_rich("[color=yellow]Inherit from this base class IState to derive on_physics_exit()[/color]")
