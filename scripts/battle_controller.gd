extends Node
class_name BattleController

# 1. pass actor dependency down via constructor
# 2. pass actor dependency through function parameter

# should Actor own its own instance of battle controller?
# or can it exist on its own entity?
# exist as its own entity because all we would need from here is to pass
# down the actor that will be performing the action
# don't need to instantiate 4 different BattleControllers only need 1

# encapsulate behavior
# of pressing buttons being handled
# picking which target to attack per avatar

# how do I know which party member will perform the action?
# what data structure can help here?
# 1. array 
# 2. stack

# swap out functions as a new party member turn begins

class ActionButtons:
	var attack_button: Button
	var pick_skills_button: Button
	var defend_button: Button
	var flee_button: Button
	var cancel_button: Button
	
	func init(atk_btn: Button, pick_skills_btn: Button, def_btn: Button, flee_btn: Button, cancel_btn: Button):
		attack_button = atk_btn
		pick_skills_button = pick_skills_btn
		defend_button = def_btn
		flee_button = flee_btn
		cancel_button = cancel_btn


func bind_actions(buttons: ActionButtons):
	buttons.attack_button.pressed.connect(on_attack_button_pressed)
	buttons.pick_skills_button.pressed.connect(on_pick_skills_button_pressed)
	buttons.defend_button.pressed.connect(on_defend_button_pressed)
	buttons.flee_button.pressed.connect(on_flee_button_pressed)
	
func unbind_actions(buttons: ActionButtons):
	Utility.disconnect_all_signal_connections(buttons.attack_button.pressed)
	Utility.disconnect_all_signal_connections(buttons.defend_button.pressed)
	Utility.disconnect_all_signal_connections(buttons.cancel_button.pressed)
	Utility.disconnect_all_signal_connections(buttons.pick_skills_button.pressed)

func on_attack_button_pressed():
	print("attack button pressed")
	
func on_pick_skills_button_pressed():
	print("pick skills button pressed")
	
func on_defend_button_pressed():
	print("defend skills button pressed")

func on_flee_button_pressed():
	print("flee button pressed")

func on_cancel_button_pressed():
	print("cancel button pressed")
