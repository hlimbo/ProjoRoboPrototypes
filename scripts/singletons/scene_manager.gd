extends Node

func change_scene(scene_path: String):
	var err = get_tree().change_scene_to_file(scene_path)
	if err != OK:
		print_rich("[color=red]changing scene failed. Error code: %d [/color]" % err)
