extends BaseResource
# Describes the positive or negative effect an Actor can have
# and the effects a Skill can apply to a target Actor
class_name StatusEffect

@export var name: String
@export var description: String
# Duration types
# 1. INFINITE - applies until battle is over
# 2. TURN - applies for X number of turns
# 3. SECONDS - applies for X seconds
@export var duration_type: String
@export var duration: float

@export var modifiers: Array[Modifier] = []

# used to determine if the status effect is the following:
# 1. positive
# 2. negative
@export var effect_type: String

func get_modifiers() -> Array[Modifier]:
	return modifiers
