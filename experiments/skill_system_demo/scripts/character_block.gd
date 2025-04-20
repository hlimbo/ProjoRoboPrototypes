extends Node
class_name CharacterBlock

@onready var health: StatDemoView = $StatAttributes/StatsContainer/Health
@onready var energy: StatDemoView = $StatAttributes/StatsContainer/Energy
@onready var strength: StatDemoView = $StatAttributes/StatsContainer/Strength
@onready var toughness: StatDemoView = $StatAttributes/StatsContainer/Toughness
@onready var speed: StatDemoView = $StatAttributes/StatsContainer/Speed
@onready var skills_container: SkillDemoLoader = $SkillButtons/ScrollContainer/SkillsContainer
@onready var status_effect_loader: StatusEffectLoader = $StatusEffects/ScrollContainer/StatusEffectLoader


func set_stats(hp: float, ep: float, stre: float, tou: float, spd: float):
	health.set_stat_value(hp)
	energy.set_stat_value(ep)
	strength.set_stat_value(stre)
	toughness.set_stat_value(tou)
	speed.set_stat_value(spd)
