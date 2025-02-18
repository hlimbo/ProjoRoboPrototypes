extends BaseResource
class_name Skill

@export var cost: int
@export var attack: int
@export var name: String
@export var description: String


func _init(p_cost = 0, p_attack = 0, p_name = "skill_resource"):
	cost = p_cost
	attack = p_attack
	name = p_name
