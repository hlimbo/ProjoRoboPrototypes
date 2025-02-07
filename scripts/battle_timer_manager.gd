extends Node
class_name BattleTimerManager 

func pause_actor(actor: Actor):
	actor.toggle_motion(true)
	# disable attack hitbox if in the middle of attacking to avoid damaging the other actor
	if actor.motion_state == Constants.Active_Battle_State.ATTACK:
		actor.toggle_hitbox(false)
	
func resume_actor(actor: Actor):
	actor.toggle_motion(false)
	# resume attacking if in attack state
	if actor.motion_state == Constants.Active_Battle_State.ATTACK:
		actor.toggle_hitbox(true)

func pause_actors(actors: Array[Actor]):
	for actor in actors:
		pause_actor(actor)

func pause_actors_excluding(actors: Array[Actor], excluded_actors: Array[Actor]):
	for actor in actors:
		if !excluded_actors.has(actor):
			pause_actor(actor)
			
func resume_actors(actors: Array[Actor]):
	for actor in actors:
		resume_actor(actor)
		
func resume_actors_excluding(actors: Array[Actor], excluded_actor: Actor):
	for actor in actors:
		if actor != excluded_actor:
			resume_actor(actor)
