extends IAvatarState
class_name ExecutingMoveState

func on_enter():
	# move towards end of exe immediately
	avatar.progress_ratio = 1
