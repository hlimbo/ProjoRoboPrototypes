extends BaseResource
class_name Skill

@export var name: String
@export var energy_type: String
@export var description: String
@export var cost: float

# FUTURE CONSIDERATION
# should there be a skill level in here?
# would it affect the casting speed? amount of damage?
# this would require a skill level table

# these will apply stat modifications as soon as this skill is applied to a target
# key - modifier name string | value - Modifier reference
@export var modifiers: Dictionary = {}

# represents the buffs and debuffs that can be applied to a target
@export var buffs: Array[StatusEffect] = []
@export var debuffs: Array[StatusEffect] = []

func _init(p_cost = 0, p_name = "skill_resource"):
	cost = p_cost
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
