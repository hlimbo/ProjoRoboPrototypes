extends BaseResource
class_name LootItem

@export var item_name: String
@export var description: String
@export var rarity: int

func is_equal(other: LootItem) -> bool:
	return item_name == other.item_name and description == other.description and rarity == other.rarity
