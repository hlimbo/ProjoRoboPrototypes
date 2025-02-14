# Finite State Machine
extends Node
class_name Fsm

# key - UI_Battle_State | Active_Battle_State (enum) -- enums can be converted to int
# value - IState Object
var state_map: Dictionary = {}
# gdscript doesn't support union types... https://github.com/godotengine/godot-proposals/issues/737?utm_source=chatgpt.com
# UI_Battle_State | Active_Battle_State (enum)
var current_state: int = 0
var old_state: int = 0

@export var can_physics_process_tick: bool = true
@export var can_process_tick: bool = true
@export var can_input_tick: bool = true

func set_physics_process_tick(enable: bool):
	set_physics_process(enable)
	can_physics_process_tick = enable
	
func set_process_tick(enable: bool):
	set_process(enable)
	can_process_tick = enable
	
func set_input_tick(enable: bool):
	set_process_input(enable)
	can_input_tick = enable

func init_state_map(new_state_map: Dictionary):
	for state_enum in new_state_map:
		state_map[state_enum] = new_state_map[state_enum]

func transition_to(new_state: int):
	if new_state not in state_map:
		print_rich("[color=red]Invalid State: %d[/color]" % new_state)
		return
	
	var old_state_obj: IState = state_map[current_state]
	old_state_obj.on_exit()
	old_state_obj.on_physics_exit()
	var new_battle_state: IState = state_map[new_state]
	new_battle_state.on_physics_enter()
	new_battle_state.on_enter()
	old_state = current_state
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
