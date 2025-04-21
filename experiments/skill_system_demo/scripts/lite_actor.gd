# A light representation of what an Actor would be for demo purposes only
# and to understand how to properly structure code of this size
extends Node
class_name LiteActor

@onready var status_effects: StatusEffectsComponent = $StatusEffects
@export var stat_attributes = StatAttributeSet.new()
