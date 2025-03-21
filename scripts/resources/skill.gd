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
@export var modifiers: Array[Modifier] = []

# represent effects that can be given to an actor target(s)
@export var status_effects: Array[StatusEffect] = []

# represents the buffs and debuffs that can be applied to a target
@export var buffs: Array[StatusEffect] = []
@export var debuffs: Array[StatusEffect] = []

func _init(p_cost = 0, p_name = "skill_resource"):
	cost = p_cost
	name = p_name
