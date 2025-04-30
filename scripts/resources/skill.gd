extends BaseResource
class_name Skill

@export var name: String
@export_enum("FIRE", "WOOD", "WATER", "EARTH", "ELECTRIC", "WIND", "AU", "AI")
var energy_type: String
@export var description: String

# FUTURE CONSIDERATION
# should there be a skill level in here?
# would it affect the casting speed? amount of damage?
# this would require a skill level table

# these will apply stat modifications as soon as this skill is applied to a target
# things like energy cost can be added here
@export var modifiers: Dictionary[String, Modifier] = {}

# represents the buffs and debuffs that can be applied to a target
@export var buffs: Array[StatusEffect] = []
@export var debuffs: Array[StatusEffect] = []

#  These represent the "if conditions" in code that has a few use cases:
# 1. whether or not to activate this skill
# 2. whether or not to apply stat bonuses
# 3. whether or not to apply stat penalties
@export var rule_set: RuleJsonObject

func _init(p_name = "skill_resource"):
	name = p_name

func get_modifiers() -> Array[Modifier]:
	var mods: Array[Modifier]
	# odd way of ensuring these get converted to the type of element this array supports...
	mods.assign(modifiers.values())
	assert(mods != null)
	return mods
	
func get_modifier(mod_name: String) -> Modifier:
	assert(mod_name in modifiers)
	return modifiers[mod_name]
