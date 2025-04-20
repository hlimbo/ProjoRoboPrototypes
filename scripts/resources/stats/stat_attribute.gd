# A wrapper around a float value
# that represents a stat value in game
# It can be observed through signals
extends BaseResource
class_name StatAttribute

signal on_value_changed(new_value: float)

@export var value: float = 0.0

func set_value(new_value: float):
	value = new_value
	on_value_changed.emit(value)
