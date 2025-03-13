extends BaseResource
#  Class responsible for containing data to either
# positively or negatively affect a stat value
class_name Modifier

# determines what stat type to modify from base_stats.gd
@export var stat_type_category: String

# determines the denomination of the stat's value. It can be the following:
# 1. flat
# 2. percentage
@export var stat_value_type: String

@export var stat_value: float
