extends BaseResource
class_name Skill

@export var cost: int
@export var attack: int
@export var name: String
@export var description: String

# string tags that are applied to target either as buff or debuff
@export var target_buffs: Array[String]
@export var target_debuffs: Array[String]

signal on_skill_start(skill: Skill, source_actor: Actor, target_actors: Array[Actor])
signal on_skill_end(skill: Skill, source_actor: Actor, target_actors: Array[Actor])

func _init(p_cost = 0, p_attack = 0, p_name = "skill_resource"):
	cost = p_cost
	attack = p_attack
	name = p_name
