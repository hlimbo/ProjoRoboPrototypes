extends Node

# disconnects all connections from a signal
func disconnect_all_signal_connections(sig: Signal):
	# https://docs.godotengine.org/en/stable/classes/class_signal.html#class-signal-method-get-connections
	var connections = sig.get_connections()
	for connection in connections:
		sig.disconnect(connection.callable)


# Since godot doesn't support generic types, after obtaining the random item,
# caller of this function will need to cast the return type Variant to the type they expect to use
func generate_random_weight(items: Array, weights: Array[float]) -> Variant:
	assert(len(items) == len(weights), "items length must match weights length")
	
	# 1. sum weights
	var sum = 0
	for weight in weights:
		sum += weight
		
	# 2. pick a random weight between 0 and sum inclusive
	var random_weight = randf_range(0, sum)
	# assign to last item in array assuming the number it picks matches the sum of the weights
	var random_index = len(items) - 1
	# subtract until the random_weight < 0, then it is known it falls between the weight ranges
	for i in range(len(weights)):
		random_weight -= weights[i]
		if random_weight < 0:
			random_index = i
			break
	
	return items[random_index]

# used to verify weighted rng algorithm
func run_weighted_rng_sim(items: Array, weights: Array[float], sim_count: int):
	var total_weights: float = 0
	# key - item
	# value - average = times picked by random number generator / sim_count
	var actual_item_averages: Dictionary = {}
	var expected_item_averages: Dictionary = {}
	for weight in weights:
		total_weights += weight
	
	# compute expected average per item
	var i: int = 0
	for item in items:
		var curr_weight: float = weights[i]
		expected_item_averages[item] = curr_weight / total_weights
		i += 1
	
	# run simulation to find actual averages
	for item in items:
		actual_item_averages[item] = 0
	
	for j in range(sim_count):
		var item = Utility.generate_random_weight(items, weights)
		actual_item_averages[item] += 1
		
	for item in items:
		actual_item_averages[item] /= float(sim_count)
		
	for item in items:
		print("item_name: %s -> expected: %f | actual %f" % [item.item_name, expected_item_averages[item], actual_item_averages[item]])

	# this should add up to 1 for both expected total and actual total
	var expected_total: float = 0
	for item in expected_item_averages:
		expected_total += expected_item_averages[item]

# assumes folder contains all files and not nested folders
func load_resources_from_folder(folder_path: String) -> Array[Resource]:
	var resources: Array[Resource] = []
	var dir = DirAccess.open(folder_path)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name != "":
			# exclude .import files as those are internal to godot engine
			if !dir.current_is_dir() and !file_name.ends_with(".import"):
				var resource_path = folder_path + "/" + file_name
				var resource = load(resource_path)
				resources.append(resource)

			file_name = dir.get_next()

		dir.list_dir_end()
	else:
		print("Failed to open directory:", folder_path)

	return resources

# verifies if the node is running in its own scene and not in an ancestor node's scene
func is_running_on_own_scene(node: Node) -> bool:
	assert(is_instance_valid(node))
	assert(is_instance_valid(node.get_tree().current_scene))
	
	print("current scene name: ", node.get_tree().current_scene.name)
	print("node name: ", node.name)
	return node.get_tree().current_scene == node

func pick_unique_random_elements(items: Array, pick_count: int) -> Array:
	assert(len(items) >= pick_count)
	
	var copy: Array = items.duplicate(true)
	var upper_limit: int = len(copy)
	var output: Array = []
	
	for i in range(pick_count):
		var random_index: int = randi() % upper_limit
		output.append(copy[random_index])
		
		# swap
		var temp = copy[random_index]
		copy[random_index] = copy[upper_limit - 1]
		copy[upper_limit - 1] = temp
		upper_limit -= 1
	
	return output
	
func convert_percent_to_flat_modifier(stat_attr_set: StatAttributeSet, modifier: Modifier) -> Modifier:
	const valid_modifier_types = [Constants.MODIFIER_FLAT, Constants.MODIFIER_PERCENT]
	const valid_stat_attributes = [
		Constants.STAT_HP, 
		Constants.STAT_ENERGY, 
		Constants.STAT_SPEED, 
		Constants.STAT_STRENGTH, 
		Constants.STAT_TOUGHNESS,
		Constants.STAT_NONE,
	]
	
	assert(valid_modifier_types.has(modifier.modifier_type))
	assert(valid_stat_attributes.has(modifier.stat_category_type_src))
	
	if modifier.modifier_type == Constants.MODIFIER_FLAT:
		return modifier
	
	var flat_modifier = Modifier.new(Constants.STAT_NONE, modifier.stat_category_type_target, Constants.MODIFIER_FLAT, 0)
	flat_modifier.is_positive = modifier.is_positive
	var percent: float = modifier.stat_value / 100
	
	match modifier.stat_category_type_src:
		Constants.STAT_HP:
			flat_modifier.stat_value = stat_attr_set.hp.value * percent
		Constants.STAT_ENERGY:
			flat_modifier.stat_value = stat_attr_set.energy.value * percent
		Constants.STAT_STRENGTH:
			flat_modifier.stat_value = stat_attr_set.strength.value * percent
		Constants.STAT_TOUGHNESS:
			flat_modifier.stat_value = stat_attr_set.toughness.value * percent
		Constants.STAT_SPEED:
			flat_modifier.stat_value = stat_attr_set.speed.value * percent
		
	return flat_modifier
	
func convert_to_absolute_value(modifier: Modifier) -> Modifier:
	if modifier.stat_value > 0:
		modifier.is_positive = true
	else:
		modifier.is_positive = false
		modifier.stat_value = absf(modifier.stat_value)
		
	return modifier
