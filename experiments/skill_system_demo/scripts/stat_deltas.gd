extends Node
class_name StatDeltas

@onready var health: StatDemoView = $Health
@onready var energy: StatDemoView = $Energy
@onready var strength: StatDemoView = $Strength
@onready var toughness: StatDemoView = $Toughness
@onready var speed: StatDemoView = $Speed


func set_deltas(hp: float, en: float, str: float, tou: float, spd: float):
	var keys: Array[StatDemoView] = [health, energy, strength, toughness, speed]
	var values: Array[float] = [hp, en, str, tou, spd]
	
	for i in range(len(keys)):
		keys[i].set_stat_value(values[i])
