extends BaseResource
class_name AvatarData

@export var avatar_name: String
@export var level: int
@export var current_experience: float
@export var max_experience_per_level: float
@export var bot_type: String
@export var energy_type: String
# the order in which the data gets displayed in a layout view
@export var ordinal: int
@export var avatar_icon: Texture2D
# this is used to preview what the bot will look like in the digital bank
@export var avatar_preview: PackedScene
# used to detemine if avatar is an enemy or party member
@export var avatar_type: Constants.Avatar_Type
