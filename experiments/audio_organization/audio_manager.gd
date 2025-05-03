extends Node
class_name AudioManager
# AudioManager Singleton

@export var audio_table: Dictionary[String, AudioStreamPlayer] = {}
@export var audio_list_table: Dictionary[String, AudioList] = {}

func play_audio_stream(name: String):
	audio_table[name].play()
	
func pause_audio_stream(name: String):
	audio_table[name].stream_paused = true
	
func resume_audio_stream(name: String):
	audio_table[name].stream_paused = false
	
func stop_audio_stream(name: String):
	audio_table[name].stop()

func play_audio_list(name: String):
	audio_list_table[name].play()
	
func pause_audio_list(name: String):
	audio_list_table[name].pause()
	
func resume_audio_list(name: String):
	audio_list_table[name].resume()

func stop_audio_list(name: String):
	audio_list_table[name].reset()
