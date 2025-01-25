extends Resource
# since gdscript is duck-typed and doesn't support interfaces as of 4.3
# all classes that need to calculate damage will extend from this class
class_name IDamageCalculator

signal on_damage_received(damage_receiver: Avatar, damage_dealer: Avatar)

func calculate_damage(_damage_receiver: Avatar, _damage_dealer: Avatar) -> int:
	print("Base Class IDamageCalculator")
	return 0
