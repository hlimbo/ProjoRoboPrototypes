extends Control
class_name StatusEffectRow

@export var status_effect: StatusEffect

@onready var status_effect_label: Label = $StatusEffectLabel
@onready var duration_label: Label = $DurationLabel
@onready var duration_type_label: Label = $DurationTypeLabel


func update_fields(effect: StatusEffect):
	status_effect = effect
	status_effect_label.set_deferred("text", status_effect.name)
	duration_label.set_deferred("text", "%d" % int(status_effect.duration))
	duration_type_label.set_deferred("text", status_effect.duration_type)
