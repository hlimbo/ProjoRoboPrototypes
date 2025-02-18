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
