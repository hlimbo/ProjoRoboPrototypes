extends BaseResource
class_name Skill

@export var cost: float
@export var attack: float
@export var name: String
@export var description: String
@export var energy_type: String

# string tags that are applied to target either as buff or debuff
@export var target_buffs: Array[String] = []
@export var target_debuffs: Array[String] = []

func _init(p_cost = 0, p_attack = 0, p_name = "skill_resource"):
	cost = p_cost
	attack = p_attack
	name = p_name
