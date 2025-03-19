extends BaseResource
#  Class responsible for containing data to either
# positively or negatively affect a stat value
class_name Modifier

# determines what stat type to modify from base_stats.gd
@export var stat_category_type_src: String = "hp"
# determines what stat type to apply the changes to from base_stats.gd
@export var stat_category_type_target: String = "hp"

# determines the denomination of the stat's value. It can be the following:
# 1. flat
# 2. percentage
@export var stat_value_type: String = "flat"

@export var stat_value: float = 0

func _init(_stat_category_type_src: String = "hp", _stat_category_type_target = "hp", _stat_value_type: String = "flat", _stat_value: float = 0):
	stat_category_type_src = _stat_category_type_src
	stat_category_type_target = _stat_category_type_target
	stat_value_type = _stat_value_type
	stat_value = _stat_value
