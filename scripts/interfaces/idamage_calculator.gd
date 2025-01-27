extends Resource
# since gdscript is duck-typed and doesn't support interfaces as of 4.3
# all classes that need to calculate damage will extend from this class
class_name IDamageCalculator

signal on_damage_received(damage_receiver: Actor, damage_dealer: Actor, damage: int)

func calculate_damage(_damage_receiver: Actor, _damage_dealer: Actor) -> int:
	print("Base Class IDamageCalculator")
	return 0
