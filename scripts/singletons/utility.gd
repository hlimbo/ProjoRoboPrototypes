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

func load_resources_from_folder(folder_path: String) -> Array[Resource]:
	var resources: Array[Resource] = []
	var dir = DirAccess.open(folder_path)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name != "":
			# exclude .import files as those are internal to godot engine
			if !file_name.ends_with(".import"):
				var resource_path = folder_path + "/" + file_name
				var resource = load(resource_path)
				resources.append(resource)

			file_name = dir.get_next()

		dir.list_dir_end()
	else:
		print("Failed to open directory:", folder_path)

	return resources
