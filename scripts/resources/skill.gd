extends BaseResource
class_name Skill

@export var name: String
@export var cost: float
# TODO: remove
@export var damage: float
@export var description: String
@export var energy_type: String

# FUTURE CONSIDERATION
# should there be a skill level in here?
# would it affect the casting speed? amount of damage?
# this would require a skill level table

# can either apply damage or healing to hp stat
@export var hp_modifier: Modifier

# represent effects that can be given to an actor target(s)
@export var status_effects: Array[StatusEffect] = []

# represents the buffs and debuffs that can be applied to a target
@export var buffs: Array[String] = []
@export var debuffs: Array[String] = []

func _init(p_cost = 0, p_damage: float = 0, p_name = "skill_resource"):
	cost = p_cost
	damage = p_damage
	name = p_name
