extends IAvatarState
class_name MoveSelectionState

func on_enter():
	avatar.toggle_motion(true)
	
func on_exit():
	avatar.toggle_motion(false)
