# Think this should be a singleton in order to test things in different contexts easily
# using the autoload function godot offers out of the box
extends Node

@export var damage_calculator: IDamageCalculator
