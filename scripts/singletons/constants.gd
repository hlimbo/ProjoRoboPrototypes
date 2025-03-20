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

enum Avatar_Type {
	PARTY_MEMBER,
	ENEMY
}

enum Actor_Type {
	PARTY_MEMBER,
	ENEMY
}

enum Energy_Type {
	FIRE,
	WOOD,
	WATER,
	EARTH,
	ELECTRIC,
	WIND,
	AU, # Gold
	AI, # Artificial Intelligence
}

enum Creature_Type {
	ROBOT,
	AUTOMATON,
	ANDROID,
}

# Used to determine which ui layout a cell belongs to
# Primarily used to handle moving bot data between party and grid view layouts
const PARTY_MEMBER_SLOTS = "party_member_slots"
const DIGITAL_BANK_SLOTS = "digital_bank_slots"

# keeping this as a list of strings as there may be more added/removed in future
# plus easier to debug to see what status effects an actor has during gameplay
const STATUS_EFFECTS = [
	"break",
	"overheat",
	"paralyze",
	"burn",
	"slow",
]

#region Modifier Value Types
const MODIFIER_FLAT = "flat"
const MODIFIER_PERCENT = "percent"
#endregion

#region Stat Attribute Labels
const STAT_HP = "hp"
const STAT_STRENGTH = "strength"
const STAT_ENERGY = "energy"
const STAT_TOUGHNESS = "toughness"
const STAT_SPEED = "speed"
const STAT_NONE = "no_stat"
#endregion
