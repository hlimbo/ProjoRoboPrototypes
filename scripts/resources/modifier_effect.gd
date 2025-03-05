extends BaseResource
#  can either be a buff or a debuff
class_name ModifierEffect

@export var name: String
@export var description: String
# Types
# Instant - applied as soon as it is in effect
# Permanent - applied for the duration of the battle. Can be removed by another modifier effect
# Turn - the number of turns this modifier lasts
# Seconds - the number of seconds this modifier lasts
@export var duration_type: String
#  Instant - 0 duration
#  Permanent -  -1
@export var duration: float
