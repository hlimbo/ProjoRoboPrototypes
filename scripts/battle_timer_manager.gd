extends Node
class_name BattleTimerManager 

func pause_actor(actor: Actor):
	actor.toggle_motion(true)
	
func resume_actor(actor: Actor):
	actor.toggle_motion(false)

func pause_actors(actors: Array[Actor]):
	for actor in actors:
		pause_actor(actor)
	
func resume_actors(actors: Array[Actor]):
	for actor in actors:
		resume_actor(actor)
		
func resume_actors_excluding(actors: Array[Actor], excluded_actor: Actor):
	for actor in actors:
		if actor != excluded_actor:
			resume_actor(actor)
