extends Resource
# this exposes this new Resource type in the editor to select
class_name HelloWoi

# similar to scriptable objects in unity
# can recreate DataTables and CurveTables with resource scripts
# DataTables are String mapped to a custom struct
# Source: https://docs.godotengine.org/en/4.3/tutorials/scripting/resources.html#creating-your-own-resources
@export var health: int # @export keyword exposes fields to the godot inspector
@export var sub_resource: Resource
@export var strings: PackedStringArray


# Set every param to have its own default value; otherwise problems arise with creating 
# and editing resource via inspector
func _init(p_health = 0, p_sub_resource = null, p_strings = []):
	health = p_health
	sub_resource = p_sub_resource
	strings = p_strings
	
func print_all_properties():
	for prop in get_property_list():
		var prop_name = prop.name
		var prop_value = get(prop_name)
		print("%s: %s" % [prop_name, str(prop_value)])
