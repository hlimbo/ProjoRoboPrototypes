extends BaseResource
# Describes the positive or negative effect an Actor can have
# and the effects a Skill can apply to a target Actor
class_name StatusEffect

@export var name: String
@export var description: String
# Duration types
# 1. ONE-SHOT - applies until battle is over
# 2. TURN - applies for X number of turns
# 3. SECONDS - applies for X seconds
@export_enum("ONE-SHOT", "TURN", "SECONDS")
var duration_type: String
@export var duration: float
# examples include DOT damage or health regen
@export var is_applied_over_time: bool = false
# does this affect current owner of status effect or others?
@export var can_affect_self: bool = true

@export var modifiers: Dictionary[String, Modifier] = {}

# used to determine if the status effect is the following:
# 1. positive
# 2. negative
@export_enum("positive", "negative")
var effect_type: String

# max number of times the same status effect can be applied to a target
@export var stack_cap: int

func get_modifiers() -> Array[Modifier]:
	var mods = modifiers.values() as Array[Modifier]
	assert(mods != null)
	return mods

func get_modifier(mod_name: String) -> Modifier:
	var modifier = modifiers[mod_name] as Modifier
	assert(modifier != null)
	return modifier

func _init(name = "Placeholder Effect Name"):
	self.name = name
