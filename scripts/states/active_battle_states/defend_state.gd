extends IActorState
class_name DefendState

func on_enter():
	var avatar: Avatar = actor.avatar
	avatar.avatar_data.current_stats.defense += avatar.avatar_data.current_stats.defense * 0.25
	print ("%s defense is now at %d" % [avatar.avatar_data.avatar_name, avatar.avatar_data.current_stats.defense])
	actor.start_defend()

func on_exit():
	var avatar: Avatar = actor.avatar
	avatar.avatar_data.current_stats.defense = avatar.avatar_data.initial_stats.defense
	print ("%s defense end with def at %d" % [avatar.avatar_data.avatar_name, avatar.avatar_data.current_stats.defense])
	# turn off shield
	actor.defense_node.visible = false
