extends IConditional
class_name PercentChance

# current chance for something to occur or not
# to simulate chance, you can pass in a random number b/w 0 and 1
@export_range(0.0, 1.0)
var curr_chance: float = 0.0
# target chance - minimum required percentage to allow something to occur
@export_range(0.0, 1.0)
var target_chance: float = 0.0

func evaluate() -> bool:
	return curr_chance >= target_chance
