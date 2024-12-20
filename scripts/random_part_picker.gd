extends Node

func _ready() -> void:
	pick_parts()


func _process(delta: float) -> void:
	pass
	
func get_filenames(dir_path: String) -> PackedStringArray:	
	var filenames: PackedStringArray = []
	var dir = DirAccess.open(dir_path)
	assert(dir != null and dir.dir_exists(""), "unable to open dir: %s. Ensure folder path exists in FileSystem" % dir_path)
	filenames.append_array(dir.get_files())
	return filenames

func pick_parts():
	var root_path: String = "res://nodes/monsters/parts"
	
	var required_parts: PackedStringArray = [
		"%s/base_body_types" % root_path,
		"%s/arm_types" % root_path,
		"%s/leg_types" % root_path,
		"%s/eye_types" % root_path,
		"%s/mouth_types" % root_path
	]
	
	var optional_parts: PackedStringArray = [
	 	"%s/ear_types" % root_path,
		"%s/horn_types" % root_path,
		"%s/nose_types" % root_path,
		"%s/antenna_types" % root_path
	]
	
	var paths: PackedStringArray = []
	paths.append_array(required_parts)
	paths.append_array(optional_parts)
	
	# key - body_part directory path (String)
	# value - random body part picked (String)
	var body_part_to_random_part = {}
	for path in paths:
		var filenames: PackedStringArray = get_filenames(path)
		body_part_to_random_part[path] = filenames[randi_range(0, len(filenames) - 1)]

		## 50% chance to not select a random optional part
		#if optional_parts.has(path):
			#if randi() % 2 < 1:
				#body_part_to_random_part[path] = "none"
			#else:
				#body_part_to_random_part[path] = filenames[randi_range(0, len(filenames) - 1)]
		#else:
			#body_part_to_random_part[path] = filenames[randi_range(0, len(filenames) - 1)]
		#
		#print("%s picked: %s" % [path, body_part_to_random_part[path]])	
	
	# load body parts
	# key - path to resource containing body part (string)
	# value - the body part resource (PackedScene)
	var res_path_to_body_part = {}
	for path in paths:
		var body_part: String = body_part_to_random_part[path]
		# skip optional body part not selected
		if body_part == "none":
			continue
		
		var part: PackedScene = load("%s/%s" % [path, body_part])
		res_path_to_body_part[path] = part
		
	
	var body_type: Node = res_path_to_body_part[required_parts[0]].instantiate()
	print("body_type: " + body_type.name)
	
	# TODO - use color picker on original art assets and randomly select from the
	# pre-defined color set using index
	# randomize color
	var random_color: Color = Color (randf(), randf(), randf(), float(1))
	print("random color %f, %f, %f, %f" % [random_color.r, random_color.g, random_color.b, random_color.a])
	(body_type.get_node("body") as CanvasItem).self_modulate = random_color

	
	# pick random face config
	var face_configs: Array[Node] = body_type.get_node("body/face").get_children()
	var face_config: Node = face_configs[randi_range(0, len(face_configs) - 1)]
	
	var eye_config: Array[Node] = face_config.get_node("eyes").get_children()
	var mouth_config: Array[Node] = face_config.get_node("mouth").get_children()
	
	# place eyes and mouth onto body
	for eye_node in eye_config:
		var eye: Node = res_path_to_body_part[required_parts[3]].instantiate()
		var eyes: Node = face_config.get_node("eyes")
		eyes.add_child(eye)
		eye.owner = body_type
		# me being confident that these nodes are always of type Node2D
		(eye as Node2D).position = (eye_node as Node2D).position
		if eye_node.name.contains("_l"):
			(eye as Sprite2D).flip_h = true
	
	for mouth_node in mouth_config:
		var mouth: Node = res_path_to_body_part[required_parts[4]].instantiate()
		var mouth_parent_node: Node = face_config.get_node("mouth")
		# Important: must set the mouth node's owner to be the root node; otherwise
		# when packing it into a scene to save, it will not be included
		# https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-method-add-child
		mouth_parent_node.add_child(mouth)
		mouth.owner = body_type
		
		(mouth as Node2D).position = (mouth_node as Node2D).position
	
	# 2 nose
	if res_path_to_body_part.has(optional_parts[2]):
		var nose: Node = face_config.get_node("nose/Marker2D")
		var nose_asset: Node = res_path_to_body_part[optional_parts[2]].instantiate()
		nose.add_child(nose_asset)
		nose_asset.owner = body_type
	
	print("\n\n\nmob config")
	print(body_type.get_tree_string_pretty())
	
	
	## pick random limbs config
	var arm_configs: Array[Node] = body_type.get_node("body/limbs/arms").get_children()
	var leg_configs: Array[Node] = body_type.get_node("body/limbs/legs").get_children()
	
	var arm_config = arm_configs[randi_range(0, len(arm_configs) - 1)]
	var leg_config = leg_configs[randi_range(0, len(leg_configs) - 1)]
	
	for arm_node in arm_config.get_children():
		var arm: Node = res_path_to_body_part[required_parts[1]].instantiate()
		var arms: Node = body_type.get_node("body/limbs/arms")
		arms.add_child(arm)
		arm.owner = body_type
		# me being confident that these nodes are always of type Node2D
		(arm as Node2D).position = (arm_node as Node2D).position
		
		# flip if left facing
		if arm_node.name.contains("_l"):
			(arm as Sprite2D).flip_h = true
	
	for leg_node in leg_config.get_children():
		var leg: Node = res_path_to_body_part[required_parts[2]].instantiate()
		var legs: Node = body_type.get_node("body/limbs/legs")
		legs.add_child(leg)
		leg.owner = body_type
		
		(leg as Node2D).position = (leg_node as Node2D).position
		
		if leg_node.name.contains("_l"):
			(leg as Sprite2D).flip_h = true
	
	## pick random accessories config
	#var accessories_config_count: int = body_type.get_node("body/accessories").get_child_count()
	var accessories_configs: Array[Node] = body_type.get_node("body/accessories").get_children()
	var accessory_config: Node = accessories_configs[randi_range(0, len(accessories_configs) - 1)]
	
	# ears
	if res_path_to_body_part.has(optional_parts[0]):
		var ears: Array[Node] = accessory_config.get_node("ears").get_children()
		for ear in ears:
			var ear_asset: Node = res_path_to_body_part[optional_parts[0]].instantiate()
			ear.add_child(ear_asset)
			ear_asset.owner = body_type
			
			if ear.name.contains("_l"):
				(ear_asset as Sprite2D).flip_h = true
	# 1 horn
	if res_path_to_body_part.has(optional_parts[1]):
		var horns: Array[Node] = accessory_config.get_node("horns").get_children()
		for horn in horns:
			var horn_asset: Node = res_path_to_body_part[optional_parts[1]].instantiate()
			horn.add_child(horn_asset)
			horn_asset.owner = body_type
			
			if horn.name.contains("_l"):
				(horn_asset as Sprite2D).flip_h = true
	
	# 3 antenna
	if res_path_to_body_part.has(optional_parts[3]):
		var antennaes: Array[Node] = accessory_config.get_node("antennaes").get_children()
		for antenna in antennaes:
			var antenna_asset: Node = res_path_to_body_part[optional_parts[3]].instantiate()
			antenna.add_child(antenna_asset)
			antenna_asset.owner = body_type
			
			if antenna.name.contains("_l"):
				(antenna_asset as Sprite2D).flip_h = true
		
	var robo = PackedScene.new()
	var err_pack = robo.pack(body_type)
	
	if err_pack != OK:
		print("something went wrong with packing the scene")
	
	var err = ResourceSaver.save(robo, "res://nodes/sprite_nodes/test_file.tscn")
	if err != OK:
		print("Error!")
	else:
		print("Save good")
	
	# 1. load files from disk per body part and store as array of strings [x]
	# 2   for every body part [x]
	#  		randomly select a filename for the body_part to use and output is full path to resource string [x]
	#     	optional parts: add an option of none in the pool. if picked, store as a pathname
	# 3 load each selection via load() function [x]
	# 4  load body first [x]
	# 5  pick random face config from body
	# 6  pick random limbs/arm config from body
			# count number of nodes contain arm substring
			# if arm is right, flip horizontally  
	# 7  pick random limbs/leg config from body
			# count number of nodes contain leg substring
			# if leg is right, flip horizontally
	# 8  pick random accessories config from body
			# count number of ears contain in ears config
			# ears, antennaes, and horns get flipped horizontally
	# 9  attach parts to monster body by setting its position to the transform point
	# 10 save as new packed scene [x]
	
	
	# TODO
	# - adjust offsets of limbs and accessories so that the parts are too far in or too far away from mob
	# - adjust rotation of limbs and accessories
	# - adjust scale of face parts (eyes, nose, mouth)
	# - build a plugin tool view
		
	#var parts_dir = DirAccess.open("res://nodes/monsters/parts")
	#if parts_dir != null:
		#print("parts dir not null")
		#var dirs: PackedStringArray = parts_dir.get_directories()
		#for dir in dirs:
			#print("directory_name " + dir)
	## load("res://nodes/monsters/parts/base_body_types")
	##pass
	
	# REQUIRED
	# body
	# arm
	# legs
	# eyes
	# mouth
	
	# OPTIONAL
	# horns
	# antenna
	# nose
	# ears
