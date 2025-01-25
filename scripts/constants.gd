# Singleton Global Class
extends Node

enum Battle_State {
	WAITING,
	MOVE_SELECTION,
	PENDING_MOVE,
	EXECUTING_MOVE,
	MOVE_CANCELLED,
	# used when receiving damage
	PAUSED,
	KNOCKBACK
}

enum Motion_State {
	NEUTRAL,
	MOVING
}
