# Finite State Machine
extends Node
class_name Fsm

# key - UI_Battle_State | Active_Battle_State (enum)
# value - IState Object
var state_map: Dictionary = {}
# gdscript doesn't support union types... https://github.com/godotengine/godot-proposals/issues/737?utm_source=chatgpt.com
# UI_Battle_State | Active_Battle_State (enum)
var current_state

func init_state_map(new_state_map: Dictionary):
	for state_enum in new_state_map:
		state_map[state_enum] = new_state_map[state_enum]

# how to handle on_enter and on_exit transitions?
func transition_to(new_state: Constants.Battle_State):
	var old_state: IState = state_map[current_state]
	old_state.on_exit()
	old_state.on_physics_exit()
	var new_battle_state: IState = state_map[new_state]
	new_battle_state.on_physics_enter()
	new_battle_state.on_enter()
	current_state = new_state

func _input(event: InputEvent):
	var current: IState = state_map[current_state]
	current.on_input(event)

func _process(delta: float):
	var current: IState = state_map[current_state]
	current.on_process(delta)

func _physics_process(delta: float):
	var current: IState = state_map[current_state]
	current.on_physics_process(delta)
