extends Node
class_name ReactionBasedButton

enum ReactionState {
	DEFAULT,
	EARLY,
	LATE,
	ON_TIME,
}

@export var key_binding: Key
@export var is_enabled: bool
@export var reaction_state: ReactionState

signal on_key_pressed(reaction_state: ReactionState)

func _ready():
	BattleSignals.on_start_turn.connect(on_start_turn)
	BattleSignals.on_end_turn.connect(on_end_turn)
	BattleSignals.on_quick_time_defend_pressed_valid.connect(on_valid_press_time)
	BattleSignals.on_quick_time_defend_late.connect(on_late_press_time)

func enable(enabled: bool):
	is_enabled = enabled

func _input(event: InputEvent) -> void:
	if is_enabled and Input.is_physical_key_pressed(key_binding):
		print("I'm pressed input with key ", key_binding)
		enable(false)
		on_key_pressed.emit(reaction_state)

func on_start_turn(actor: Actor):
	if actor.actor_type == Constants.Actor_Type.ENEMY:
		reaction_state = ReactionState.EARLY
	
func on_end_turn(actor: Actor):
	# reset party member's reaction state
	if actor.actor_type == Constants.Actor_Type.PARTY_MEMBER:
		reaction_state = ReactionState.DEFAULT
	
func on_valid_press_time():
	reaction_state = ReactionState.ON_TIME
	
func on_late_press_time():
	reaction_state = ReactionState.LATE
