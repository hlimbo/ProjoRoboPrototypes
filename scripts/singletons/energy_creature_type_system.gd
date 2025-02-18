extends Node

const STRENGTH_INDEX = 0
const WEAK_INDEX = 1

# key - Energy_Type from constants.gd
# value - array of Energy_Type where 1st element is strong against and 2nd element is weak against
var energy_effectiveness_table = {
	# cycle 1
	Constants.Energy_Type.FIRE: [Constants.Energy_Type.WOOD, Constants.Energy_Type.WATER],
	Constants.Energy_Type.WOOD: [Constants.Energy_Type.WATER, Constants.Energy_Type.FIRE],
	Constants.Energy_Type.WATER: [Constants.Energy_Type.FIRE, Constants.Energy_Type.WOOD],
	
	# cycle 2
	Constants.Energy_Type.EARTH: [Constants.Energy_Type.ELECTRIC, Constants.Energy_Type.WIND],
	Constants.Energy_Type.ELECTRIC: [Constants.Energy_Type.WIND, Constants.Energy_Type.EARTH],
	Constants.Energy_Type.WIND: [Constants.Energy_Type.EARTH, Constants.Energy_Type.ELECTRIC],
	
	# cycle 3
	Constants.Energy_Type.AU: [Constants.Energy_Type.AI, Constants.Energy_Type.AI],
	Constants.Energy_Type.AI: [Constants.Energy_Type.AU, Constants.Energy_Type.AU],
}

# key - Creature_Type from constants.gd
# value - array of Creature_Type where 1st element is strong against and 2nd element is weak against
var type_effectiveness_table = {
	Constants.Creature_Type.ROBOT: [Constants.Creature_Type.AUTOMATON, Constants.Creature_Type.ANDROID],
	Constants.Creature_Type.AUTOMATON: [Constants.Creature_Type.ANDROID, Constants.Creature_Type.ROBOT],
	Constants.Creature_Type.ANDROID: [Constants.Creature_Type.ROBOT, Constants.Creature_Type.AUTOMATON],
}

func energy_strong_against(key_energy: Constants.Energy_Type) -> Constants.Energy_Type:
	return energy_effectiveness_table[key_energy][STRENGTH_INDEX]
	
func energy_weak_against(key_energy: Constants.Energy_Type) -> Constants.Energy_Type:
	return energy_effectiveness_table[key_energy][WEAK_INDEX]
	
func type_strong_against(key_type: Constants.Creature_Type) -> Constants.Creature_Type:
	return type_effectiveness_table[key_type][STRENGTH_INDEX]
	
func type_weak_against(key_type: Constants.Creature_Type) -> Constants.Creature_Type:
	return type_effectiveness_table[key_type][WEAK_INDEX]

# used to check for strength/weak relationships
func test_fn():
	for key in energy_effectiveness_table:
		var key_str = Constants.Energy_Type.keys()[key]
		var strength = Constants.Energy_Type.keys()[energy_effectiveness_table[key][STRENGTH_INDEX]]
		var weak = Constants.Energy_Type.keys()[energy_effectiveness_table[key][WEAK_INDEX]]
		print("%s strength: %s | weak: %s" % [key_str, strength, weak])
	
	print("bot types")
	for key in type_effectiveness_table:
		var key_str = Constants.Creature_Type.keys()[key]
		var strength = Constants.Creature_Type.keys()[type_effectiveness_table[key][STRENGTH_INDEX]]
		var weak = Constants.Creature_Type.keys()[type_effectiveness_table[key][WEAK_INDEX]]
		print("%s strength: %s | weak: %s" % [key_str, strength, weak])
