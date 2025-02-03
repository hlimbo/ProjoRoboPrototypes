extends Node

signal on_start_turn(actor: Actor)
signal on_resume_play()
signal on_pause_play(actor: Actor)
signal on_end_turn(actor: Actor)

# used to know if player pressed button at the right time (reaction based)
signal on_quick_time_defend_pressed_valid
# used to know if player pressed button too late
signal on_quick_time_defend_late

# this should get emitted until progress_ratio reaches 1
signal on_executing_action(actor: Actor)

signal on_executed_action(actor: Actor)

# used to determine when an interrupt happens
# an interrupt can occur if actor receives damage from another actor
# damage can come from either basic attacks or skills
# interruptor - actor interrupting the other actor
# interruptee - actor being interrupted by the other actor
# signal on_interrupt(interruptor: Actor, interruptee: Actor)
