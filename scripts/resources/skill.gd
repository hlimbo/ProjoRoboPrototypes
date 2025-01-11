extends Resource
class_name Skill

@export var cost: int
@export var attack: int
@export var name: String
@export var description: String


func _init(p_cost = 0, p_attack = 0, p_name = "skill_resource"):
	cost = p_cost
	attack = p_attack
	name = p_name
	
func print_all_properties():
	for prop in get_property_list():
		var prop_name = prop.name
		var prop_value = get(prop_name)
		print("%s: %s" % [prop_name, str(prop_value)])
