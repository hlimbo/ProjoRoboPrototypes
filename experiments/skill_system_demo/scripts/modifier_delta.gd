extends Resource
class_name ModifierDelta

@export var hp: Modifier
@export var energy: Modifier
@export var strength: Modifier
@export var toughness: Modifier
@export var speed: Modifier

func _init(_hp: Modifier = Modifier.create_hp(), _energy: Modifier = Modifier.create_energy(), _strength: Modifier = Modifier.create_strength(), _toughness: Modifier = Modifier.create_toughness(), _speed: Modifier = Modifier.create_speed()):
	hp = _hp
	energy = _energy
	strength = _strength
	toughness = _toughness
	speed = _speed
