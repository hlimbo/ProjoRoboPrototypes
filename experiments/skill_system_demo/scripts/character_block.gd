extends IObserverResource
class_name CharacterBlock

@export var player: LiteActor

@onready var health: StatDemoView = $StatAttributes/StatsContainer/Health
@onready var energy: StatDemoView = $StatAttributes/StatsContainer/Energy
@onready var strength: StatDemoView = $StatAttributes/StatsContainer/Strength
@onready var toughness: StatDemoView = $StatAttributes/StatsContainer/Toughness
@onready var speed: StatDemoView = $StatAttributes/StatsContainer/Speed
@onready var skills_container: SkillDemoLoader = $SkillButtons/ScrollContainer/SkillsContainer
@onready var status_effect_loader: StatusEffectLoader = $StatusEffects/ScrollContainer/StatusEffectLoader

func _ready():
	player.stat_attributes.add_listener(self)

# IObserverResource function
func notify(subject: SubjectResource):
	var stat_attributes: StatAttributeSet = subject as StatAttributeSet
	
	health.set_stat_value(stat_attributes.hp.value)
	energy.set_stat_value(stat_attributes.energy.value)
	strength.set_stat_value(stat_attributes.strength.value)
	toughness.set_stat_value(stat_attributes.toughness.value)
	speed.set_stat_value(stat_attributes.speed.value)


func set_stats(hp: float, ep: float, stre: float, tou: float, spd: float):
	health.set_stat_value(hp)
	energy.set_stat_value(ep)
	strength.set_stat_value(stre)
	toughness.set_stat_value(tou)
	speed.set_stat_value(spd)
