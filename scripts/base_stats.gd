extends RefCounted
class_name BaseStats

var name: String
var level: int
var exp_points: int
var skill_points: int

var hp: int
var attack: int
var defense: int
var speed: int


func set_stats(stats: BaseStats):
	name = stats.name
	level = stats.level
	exp_points = stats.exp_points
	skill_points = stats.skill_points
	hp = stats.hp
	attack = stats.attack
	defense = stats.defense
	speed = stats.defense
