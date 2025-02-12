extends IActorState
class_name DefendState

func on_enter():
	var avatar: Avatar = actor.avatar
	avatar.curr_stats.defense += avatar.curr_stats.defense * 0.25
	print ("%s defense is now at %d" % [avatar.curr_stats.name, avatar.curr_stats.defense])

func on_exit():
	var avatar: Avatar = actor.avatar
	avatar.curr_stats.defense = avatar.initial_stats.defense
	print ("%s defense end with def at %d" % [avatar.curr_stats.name, avatar.curr_stats.defense])
