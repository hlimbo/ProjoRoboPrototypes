# Singleton Global Class
extends Node

# TODO: rename to UI_Battle_State
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

enum Active_Battle_State {
	NEUTRAL,
	MOVING,
	DEFEND,
	ATTACK,
	SKILL,
	FLEE
}

# TODO: rename to Actor_Type and move typing up Actor class instead of avatar...
enum Avatar_Type {
	PARTY_MEMBER,
	ENEMY
}
