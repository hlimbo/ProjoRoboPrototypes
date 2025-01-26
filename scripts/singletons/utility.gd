extends Node

# disconnects all connections from a signal
func disconnect_all_signal_connections(sig: Signal):
	# https://docs.godotengine.org/en/stable/classes/class_signal.html#class-signal-method-get-connections
	var connections = sig.get_connections()
	for connection in connections:
		sig.disconnect(connection.callable)
