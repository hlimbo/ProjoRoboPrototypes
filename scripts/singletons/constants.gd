# Singleton Global Class
extends Node

# TODO: rename to UI_Battle_State
enum Battle_State {
	WAITING,
	MOVE_SELECTION,
	PENDING_MOVE,
	EXECUTING_MOVE,
	MOVE_CANCELLED,
	# used when receiving damage to temporarily pause the avatar's motion on timeline
	PAUSED,
	# moves back avatar's motion on the timeline
	KNOCKBACK
}

enum Active_Battle_State {
	NEUTRAL,
	MOVING,
	DEFEND,
	ATTACK,
	SKILL,
	FLEE,
	HURT,
	KNOCKBACK,
	CAST_SKILL
}

# TODO: rename to Actor_Type and move typing up Actor class instead of avatar...
enum Avatar_Type {
	PARTY_MEMBER,
	ENEMY
}
