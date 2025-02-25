extends BaseResource
class_name ItemQuantity

@export var item: LootItem
@export var quantity: int
# this allows one to lookup where the item is located in the array
@export var index: int
	
func is_equal(other: ItemQuantity) -> bool:
	return item.is_equal(other.item) and quantity == other.quantity and index == other.index
