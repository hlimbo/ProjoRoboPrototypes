extends Node
class_name BattleSignals

# TODO: figure out if passing in avatar or actor or something else...
# hard to figure out if don't have clear sense of what data is needed
signal on_start_turn(avatar: Avatar)
signal on_resume_play(avatar: Avatar)
signal on_pause_play(avatar: Avatar)
signal on_turn_end(avatar: Avatar)
