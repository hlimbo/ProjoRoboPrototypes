# describes the list of items needed to craft a bot
extends BaseResource
class_name Schematic

# key - item_name string
# value - SchematicRow
@export var recipe_table: Dictionary = {}
@export var creature_name: String

func _init(creature_name: String, items: Dictionary):
	self.creature_name = creature_name
	recipe_table = items
	
func get_table() -> Dictionary:
	return recipe_table
