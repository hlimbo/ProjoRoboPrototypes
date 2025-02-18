extends Resource
class_name BaseResource

# helper function since godot doesn't seem to have a built-in function to print all properties of a resource
func print_all_properties():
	for prop in get_property_list():
		var prop_name = prop.name
		var prop_value = get(prop_name)
		print("%s: %s" % [prop_name, str(prop_value)])
