extends IAvatarState
class_name WaitingState

# Problem with entering in this state is that you need to know which
# state you were in previously to properly set the avatar's state
# did it come from a paused state? did it come from executing a move state?
#func on_enter():
	## if pending move is NOT cancelled, reset progress back to 0
	## why? to ensure avatar does not jump back to beginning of timeline if being knocked back
	#if not avatar.is_knocked_back or avatar.progress_ratio == 1:
		#avatar.progress_ratio = 0 # reset back to beginning of timeline
	#
	#avatar._curr_speed = avatar.move_speed # restore movespeed
