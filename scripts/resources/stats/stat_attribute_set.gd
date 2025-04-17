# represents the stats that a bot has
# can be modified via level ups or when in battle
extends BaseResource
class_name StatAttributeSet

@export var hp: StatAttribute = StatAttribute.new()
@export var strength: StatAttribute = StatAttribute.new()
@export var energy: StatAttribute = StatAttribute.new()
@export var toughness: StatAttribute = StatAttribute.new()
@export var speed: StatAttribute = StatAttribute.new()

# TODO: create a stats csv object and pass it in here instead
func load_stats(values: Array[float]):
	assert(len(values) == 5)
	
	hp.value = values[0]
	strength.value = values[1]
	energy.value = values[2]
	toughness.value = values[3]
	speed.value = values[4]
	
	self.notify_all()

func add_listener(observer: IObserver):
	hp.add_listener(observer)
	strength.add_listener(observer)
	energy.add_listener(observer)
	toughness.add_listener(observer)
	
func remove_listener(observer: IObserver):
	hp.remove_listener(observer)
	strength.remove_listener(observer)
	energy.remove_listener(observer)
	toughness.add_listener(observer)
	
# notifies all subjects observing these stats when one of them changes
func notify_all():
	hp.notify_all()
	strength.notify_all()
	energy.notify_all()
	toughness.notify_all()
