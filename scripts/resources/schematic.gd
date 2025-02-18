# describes the list of items needed to craft a bot
extends BaseResource
class_name Schematic

# key - LootItem item_name
# value - ItemQuantity
@export var recipe_table: Dictionary
