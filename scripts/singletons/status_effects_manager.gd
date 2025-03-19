extends Node
# class: StatusEffectsManager

@export var csv_file: String = "res://resources/csv/status_effects_csv.txt"
var status_effects: StatusEffectDataContainer


func _init():
	status_effects = StatusEffectDataContainer.new()
	status_effects.load_modifiers(csv_file)
