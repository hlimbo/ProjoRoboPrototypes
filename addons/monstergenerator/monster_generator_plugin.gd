@tool
extends EditorPlugin

const resource_path: String = "res://addons/monstergenerator/monster_generator_view.tscn"
const toggle_mob_gen_dock_label: String = "Toggle MobGen Dock"
var dock_resource: Resource
var dock: Control
var is_dock_visible: bool

# UI controls from MonsterGeneratorView
var find_btn: Button
var save_btn: Button
var randomize_btn: Button
var folder_path_text: LineEdit
var file_name: LineEdit
var file_dialog: FileDialog
# Node where the randomly generated mob gets spawned at
var subroot: Marker2D



# Known Issue: if dock is manually closed via right click -> close, you must toggle its visibility twice from Project -> Tools -> Toggle Mob Gen Dock
# add plugin view to top left of godot editor
# this happens when you toggle the plugin as on in Project -> Project Settings -> Plugin
func _enter_tree() -> void:
	dock_resource = preload(resource_path)
	if dock_resource.can_instantiate():
		dock = dock_resource.instantiate()
			
		on_open_dock()
		add_tool_menu_item(toggle_mob_gen_dock_label, on_toggle_mob_gen_dock)
		# it crashes because the signal associated with the dock's path changed...
		# it also crashes if you attempt to move the dock from one location to the next....
		# dock.hidden.connect(on_close_dock)
		init_nodes()
	else:
		push_error("Unable to preload %s" % resource_path)

# remove dock when this node exits the scene tree
# this happens when you toggle the plugin as off in Project -> Project Settings -> Plugin
func _exit_tree() -> void:
	if dock and is_dock_visible:
		on_close_dock()

	if dock:
		print("freeing dock")
		remove_tool_menu_item(toggle_mob_gen_dock_label)
		dock.queue_free()

func on_toggle_mob_gen_dock():
	if is_dock_visible:
		on_close_dock()
	else:
		on_open_dock()

#  gets triggered when right-clicking on dock to close
func on_close_dock():
	is_dock_visible = false
	remove_control_from_docks(dock)
	
func on_open_dock():
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UL, dock)
	is_dock_visible = true

func init_nodes():
	find_btn = dock.get_node("GridContainer/VBoxContainer/FolderContainer/FindButton")
	save_btn = dock.get_node("GridContainer/VBoxContainer/SaveButton")
	randomize_btn = dock.get_node("GridContainer/VBoxContainer/RandomizeButton")
	folder_path_text = dock.get_node("GridContainer/VBoxContainer/FolderContainer/FolderPathText")
	file_dialog = dock.get_node("GridContainer/VBoxContainer/FolderContainer/FileDialog")
	file_name = dock.get_node("GridContainer/VBoxContainer/FileContainer/Filename")
	subroot = dock.get_node("GridContainer/CenterContainer/SubViewportContainer/SubViewport/subroot")
	
	find_btn.pressed.connect(on_find_pressed)
	save_btn.pressed.connect(on_save_pressed)
	file_dialog.dir_selected.connect(on_folder_selected)
	randomize_btn.pressed.connect(on_randomize_pressed)

func on_save_pressed():
	if folder_path_text.text.is_empty():
		push_error("Unable to save. Pick a folder path first before saving!")
	else:
		print_rich("[color=yellow][b] saving to.... %s [/b][/color]" % folder_path_text.text)
		#var packed_robo = PackedScene.new()
		#var err = robo.pack(body_type)
		#
		#if err != OK:
			#push_error("unable to pack resource. Check error logs for more info")
		#
		#err = ResourceSaver.save("%s/test_file.tscn" % folder_path_text.text)
		#if err != ok:
			#push_error("Unable to save resource. Check error logs for more info")
		#else:
			#print_rich("[color=green][b]Successfully saved file to %s/test_file.tscn[/b][/color]" % folder_path_text.text)
	
func on_find_pressed():
	file_dialog.visible = true
	file_dialog.popup_centered_ratio()

func on_folder_selected(dir: String):
	folder_path_text.text = dir
	
func on_randomize_pressed():
	print("random pressed")
	# hack - remove children from subroot... need to breakdown pick_parts() into smaller functions
	for child in subroot.get_children():
		child.queue_free()
		
	pick_parts()
	
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
		
		
	## temp - hard code body type to base_bodyE
	#var temp_part: PackedScene = load("%s/%s" % [required_parts[0], "base_bodyE.tscn"])
	#res_path_to_body_part[required_parts[0]] = temp_part
	
	var body_type: Node = res_path_to_body_part[required_parts[0]].instantiate()
	print("body_type: " + body_type.name)
	
	var blue = Color("#FF4362")
	var dark = Color("#4F3F2F")
	var green = Color("#2ECC71")
	var red = Color("#FF4362")
	var white = Color("#EEECEC")
	var yellow = Color("#FFB600")
	
	var colors: Array[Color] = [
		blue, dark, green, red, white, yellow
	]
	
	# randomize color
	var random_color: Color = colors[randi_range(0, len(colors) - 1)]
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
		eye_node.add_child(eye)
		eye.owner = body_type

		# flip horizontally if left side
		if eye_node.name.contains("_l"):
			(eye as Sprite2D).flip_h = true
	
	for mouth_node in mouth_config:
		var mouth: Node = res_path_to_body_part[required_parts[4]].instantiate()
		# Important: must set the mouth node's owner to be the root node; otherwise
		# when packing it into a scene to save, it will not be included
		# https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-method-add-child
		mouth_node.add_child(mouth)
		mouth.owner = body_type
	
	if res_path_to_body_part.has(optional_parts[2]):
		var nose: Node = face_config.get_node("nose/Marker2D")
		var nose_asset: Node = res_path_to_body_part[optional_parts[2]].instantiate()
		nose.add_child(nose_asset)
		nose_asset.owner = body_type
		
	## pick random limbs config
	var arm_configs: Array[Node] = body_type.get_node("body/limbs/arms").get_children()
	var leg_configs: Array[Node] = body_type.get_node("body/limbs/legs").get_children()
	
	var arm_config = arm_configs[randi_range(0, len(arm_configs) - 1)]
	var leg_config = leg_configs[randi_range(0, len(leg_configs) - 1)]
	
	for arm_node in arm_config.get_children():
		var arm: Node = res_path_to_body_part[required_parts[1]].instantiate()
		var arms: Node = body_type.get_node("body/limbs/arms")
		
		# flip if left facing
		var arm_sprite: Sprite2D = (arm as Sprite2D)
		if not arm_sprite:
			push_error("arm _sprite is null")
		
		# keep z-index independent from ancestor node's influence
		arm_sprite.z_as_relative = false
		
		if arm_node.name.contains("_l"):
			arm_sprite.flip_h = true
			# Note: when you flip horizontally, the offset position needs to be flipped manually
			# so that when the arm gets parented to the arm Marker2D node, it properly inherits its parent's transform properties
			arm_sprite.offset.x *= -1
			print("flipping arm_sprite: %s to %d" % [arm_sprite.name, arm_sprite.offset.x])
		
		# attaching the arm to the arm_node will inherit arm_node's transform properties
		arm_node.add_child(arm)
		# need to set arm's owner to be the root node in order to save any property changes made; otherwise property changes are not saved
		arm.owner = body_type
		
	for leg_node in leg_config.get_children():
		var leg: Node = res_path_to_body_part[required_parts[2]].instantiate()
		var legs: Node = body_type.get_node("body/limbs/legs")
		
		var leg_sprite: Sprite2D = leg as Sprite2D
		if not leg_sprite:
			push_error("leg is not a Sprite2D node")
		
		leg_sprite.z_as_relative = false
		
		if leg_node.name.contains("_l"):
			leg_sprite.flip_h = true
			leg_sprite.offset.x *= -1
			
		leg_node.add_child(leg)
		leg.owner = body_type
	
	## pick random accessories config
	#var accessories_config_count: int = body_type.get_node("body/accessories").get_child_count()
	var accessories_configs: Array[Node] = body_type.get_node("body/accessories").get_children()
	var accessory_config: Node = accessories_configs[randi_range(0, len(accessories_configs) - 1)]
	
	# ears
	if res_path_to_body_part.has(optional_parts[0]):
		var ears: Array[Node] = accessory_config.get_node("ears").get_children()
		for ear in ears:
			var ear_asset: Node = res_path_to_body_part[optional_parts[0]].instantiate()
			var ear_sprite: Sprite2D = ear_asset as Sprite2D
			
			if not ear_sprite:
				push_error("ear is not a Sprite2D node")
				
			ear_sprite.z_as_relative = false
			
			if ear.name.contains("_l"):
				ear_sprite.flip_h = true
				ear_sprite.offset.x *= -1
				
			ear.add_child(ear_asset)
			ear_asset.owner = body_type
	# horn
	if res_path_to_body_part.has(optional_parts[1]):
		var horns: Array[Node] = accessory_config.get_node("horns").get_children()
		for horn in horns:
			var horn_asset: Node = res_path_to_body_part[optional_parts[1]].instantiate()
			var horn_sprite: Sprite2D = horn_asset as Sprite2D
			
			if not horn_sprite:
				push_error("horn asset is not a Sprite2D node")
			
			if horn.name.contains("_l"):
				horn_sprite.flip_h = true
				horn_sprite.offset.x *= -1
				
			horn.add_child(horn_asset)
			horn_asset.owner = body_type
	
	# antenna
	if res_path_to_body_part.has(optional_parts[3]):
		var antennaes: Array[Node] = accessory_config.get_node("antennaes").get_children()
		for antenna in antennaes:
			var antenna_asset: Node = res_path_to_body_part[optional_parts[3]].instantiate()
			var antenna_sprite: Sprite2D = antenna_asset as Sprite2D
			if not antenna_sprite:
				push_error("antenna_asset is not a Sprite2D node")
			
			if antenna.name.contains("_l"):
				antenna_sprite.flip_h = true
				antenna_sprite.offset.x *= -1
				
			antenna.add_child(antenna_asset)
			antenna_asset.owner = body_type
	
	# attach body_type to SubViewport/placeholder
	body_type.print_tree_pretty()
	subroot.add_child(body_type)
	
	#var robo = PackedScene.new()
	#var err_pack = robo.pack(body_type)
	#
	#if err_pack != OK:
		#print("something went wrong with packing the scene")
	
	#var err = ResourceSaver.save(robo, "res://nodes/sprite_nodes/test_file.tscn")
	#if err != OK:
		#print("Error!")
	#else:
		#print("Save good")

func get_filenames(dir_path: String) -> PackedStringArray:	
	var filenames: PackedStringArray = []
	var dir = DirAccess.open(dir_path)
	assert(dir != null and dir.dir_exists(""), "unable to open dir: %s. Ensure folder path exists in FileSystem" % dir_path)
	filenames.append_array(dir.get_files())
	return filenames