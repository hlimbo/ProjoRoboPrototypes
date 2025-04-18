extends BaseResource
#  Class responsible for containing data to either
# positively or negatively affect a stat value
class_name Modifier

# determines what stat type to modify from base_stats.gd
@export var stat_category_type_src: String = Constants.STAT_NONE
# determines what stat type to apply the changes to from base_stats.gd
@export var stat_category_type_target: String = Constants.STAT_NONE

# determines the denomination of the stat's value. It can be the following:
# 1. flat
# 2. percent
@export var modifier_type: String = Constants.MODIFIER_FLAT
@export var stat_value: float = 0

func _init(_src: String = Constants.STAT_NONE, _target: String = Constants.STAT_HP, _modifier_type: String = Constants.MODIFIER_FLAT, _stat_value: float = 0):
	stat_category_type_src = _src
	stat_category_type_target = _target
	modifier_type = _modifier_type
	stat_value = _stat_value
