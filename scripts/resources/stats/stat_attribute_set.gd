# represents the stats that a bot has
# can be modified via level ups or when in battle
extends SubjectResource
class_name StatAttributeSet

@export var hp = StatAttribute.new()
@export var strength = StatAttribute.new()
@export var energy = StatAttribute.new()
@export var toughness = StatAttribute.new()
@export var speed = StatAttribute.new()

# TODO: create a stats csv object and pass it in here instead
func load_stats(values: Array[float]):
	assert(len(values) == 5)
	
	hp.value = values[0]
	strength.value = values[1]
	energy.value = values[2]
	toughness.value = values[3]
	speed.value = values[4]
	
	self.notify_all()

func set_hp(value: float):
	hp.set_value(value)
	self.notify_all()
	
func set_strength(value: float):
	strength.set_value(value)
	self.notify_all()
	
func set_energy(value: float):
	energy.set_value(value)
	self.notify_all()

func set_toughness(value: float):
	toughness.set_value(value)
	self.notify_all()
	
func set_speed(value: float):
	speed.set_value(value)
	self.notify_all()
