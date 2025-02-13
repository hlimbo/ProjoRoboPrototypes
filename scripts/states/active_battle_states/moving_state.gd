extends IActorState
class_name MovingState

var target: Actor = null

func on_enter():
	pass
	#print("start motion ", actor.avatar.curr_stats.name)
	## turn on interact area to detect when an attack animation can be simulated
	#actor.interact_area.monitoring = true
	#actor.motion_state = Constants.Active_Battle_State.MOVING
	##actor.target = target_actor

func on_physics_enter():
	pass

func on_input(event: InputEvent):
	pass

func on_process(delta: float):
	pass

func on_physics_process(delta: float):
	pass
	#if target:
		#var vel: Vector2 = actor.move_to_target(target.position)
		#actor.position += vel * delta_time
	#else:
		#var dist: float = actor.move_back_to_original_position(delta)
		#if dist <= 100:
			#actor.active_battle_state_machine.transition_to(Constants.Active_Battle_State.NEUTRAL)
			#actor.motion_state = actor.Active_Battle_State.NEUTRAL
			#actor.active_battle_state_machine.set_physics_process_tick(false)
	
func on_exit():
	pass
	#actor.active_battle_state_machine.set_physics_process_tick(true)
	#BattleSignals.on_end_turn.emit(self)

func on_physics_exit():
	pass
