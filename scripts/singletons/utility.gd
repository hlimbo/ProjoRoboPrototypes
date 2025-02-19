extends Node

# disconnects all connections from a signal
func disconnect_all_signal_connections(sig: Signal):
	# https://docs.godotengine.org/en/stable/classes/class_signal.html#class-signal-method-get-connections
	var connections = sig.get_connections()
	for connection in connections:
		sig.disconnect(connection.callable)


func generate_random_weight(items: Array[String], weights: Array[float]) -> String:
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

func load_resources_from_folder(folder_path: String) -> Array[Resource]:
	var resources: Array[Resource] = []
	var dir = DirAccess.open(folder_path)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name != "":
			if file_name.ends_with(".tres") or file_name.ends_with(".res"):
				var resource_path = folder_path + "/" + file_name
				var resource = load(resource_path)
				resources.append(resource)

			file_name = dir.get_next()

		dir.list_dir_end()
	else:
		print("Failed to open directory:", folder_path)

	return resources
