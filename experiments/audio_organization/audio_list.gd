extends Node
class_name AudioList

enum Play_Mode {
	RANDOM,
	FORWARD, # play stream-players in the order inserted in array
	BACKWARD, # play stream-players in reverse order
}

@export var play_mode: Play_Mode = Play_Mode.FORWARD
@export var audio_player: AudioStreamPlayer
# can swap out audio streams for 1 player for UI elements
@export var audio_streams: Array[AudioStream] = []

var play_index: int = 0
var prev_play_index: int = -1
var prev_audio_stream: AudioStream = null

func play():
	match play_mode:
		Play_Mode.FORWARD, Play_Mode.BACKWARD:
			play_order()
		Play_Mode.RANDOM:
			play_random()
	
	
func play_order():
	#if audio_player.playing:
		#return
	
	if play_mode == Play_Mode.FORWARD:
		play_index = (play_index + 1) % len(audio_streams)
	else:
		play_index = play_index - 1 if play_index > 0 else len(audio_streams) - 1
	
	var stream = audio_streams[play_index]
	print("playing sound: %s" % stream.resource_path)
	audio_player.set_stream(stream)
	audio_player.play()


func play_random():
	#if audio_player.playing:
		#return
		
	play_index = randi_range(0, len(audio_streams) - 1)
	var stream: AudioStream = audio_streams[play_index]
	print("playing random audio: %s" % stream.resource_path)
	audio_player.set_stream(stream)
	audio_player.play()
	
	# temporarily remove from list to avoid picking same random index on the next play
	audio_streams.remove_at(play_index)
	# add previously picked audio stream back to list of items to randomly pick from
	_add_back_to_list()
	prev_audio_stream = stream
	prev_play_index = play_index

func pause():
	assert(audio_player.stream != null)
	audio_player.stream_paused = true
	
func resume():
	assert(audio_player.stream != null)
	audio_player.stream_paused = false

func _add_back_to_list():
	if play_mode == Play_Mode.RANDOM and prev_audio_stream != null and prev_play_index > -1:
		if prev_play_index >= len(audio_streams):
			audio_streams.append(prev_audio_stream)
		else:
			audio_streams.insert(prev_play_index, prev_audio_stream)

func reset():
	play_index = 0
	# move prev player back into the list in the event Play_Mode RANDOM is selected
	_add_back_to_list()
	prev_audio_stream = null
	prev_play_index = -1
	audio_player.stop()
	audio_player.set_stream(null)
