@tool
extends EditorPlugin

const resource_path: String = "res://addons/monstergenerator/monster_generator_view.tscn"
const toggle_mob_gen_dock_label: String = "Toggle MobGen Dock"
var dock_resource: Resource
var dock: Control
var is_dock_visible: bool

##### UI controls from MonsterGeneratorView #####
var find_btn: Button
var save_btn: Button
var randomize_btn: Button
var folder_path_text: LineEdit
var file_name: LineEdit
var file_dialog: FileDialog
# Node where the randomly generated mob gets spawned at
var subroot: Marker2D

# TODO: to extend this further, I can expose a resource type that contains
# root path to art assets followed by subpaths to different parts to include it as
# that way the code can work for ANY art asset being plugged in... All that needs to be done
# is setup the nodes where the body parts will go in place
##### Paths to art assets #####
const root_path: String = "res://nodes/monsters/parts"
const base_body_path: String = "%s/base_body_types" % root_path
const arm_path: String = "%s/arm_types" % root_path
const leg_path: String = "%s/leg_types" % root_path
const eye_path: String = "%s/eye_types" % root_path
const mouth_path: String = "%s/mouth_types" % root_path
const ear_path: String = "%s/ear_types" % root_path
const horn_path: String = "%s/horn_types" % root_path
const nose_path: String = "%s/nose_types" % root_path
const antenna_path: String = "%s/antenna_types" % root_path

const required_parts: PackedStringArray = [
	base_body_path,
	arm_path,
	leg_path,
	eye_path,
	mouth_path
]

const optional_parts: PackedStringArray = [
	ear_path,
	horn_path,
	nose_path,
	antenna_path,
]

##### Colors #####
const blue = Color("#FF4362")
const dark = Color("#4F3F2F")
const green = Color("#2ECC71")
const red = Color("#FF4362")
const white = Color("#EEECEC")
const yellow = Color("#FFB600")

const colors: Array[Color] = [
	blue, dark, green, red, white, yellow
]

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
	elif file_name.text.is_empty() or !file_name.text.ends_with(".tscn"):
		push_error("Unable to save. Set a filename to save as ending in .tscn")
	elif not subroot or subroot.get_child_count() == 0:
		push_error("Unable to save. Press Randomize! button to generate a character")
	else:
		print_rich("[color=yellow][b] saving to.... %s [/b][/color]" % folder_path_text.text)
		
		var robo = PackedScene.new()
		var robo_node = subroot.get_child(0)
		var err = robo.pack(robo_node)
		
		if err != OK:
			push_error("unable to pack resource. Check error logs for more info")
			return
			
		
		err = ResourceSaver.save(robo, "%s/%s" % [folder_path_text.text, file_name.text])
		if err != OK:
			push_error("Unable to save resource. Check error logs for more info")
		else:
			print_rich("[color=green][b]Successfully saved file to %s/%s[/b][/color]" % [folder_path_text.text, file_name.text])
	
func on_find_pressed():
	file_dialog.visible = true
	file_dialog.popup_centered_ratio()

func on_folder_selected(dir: String):
	folder_path_text.text = dir
	
func on_randomize_pressed():
	# remove children from subroot so old random generation is no longer shown in the scene tree
	for child in subroot.get_children():
		child.queue_free()
		
	pick_parts()
	
func pick_parts():
	var res_path_to_body_part: Dictionary = load_and_pick_parts()
	
	# pick body
	var body_type: Node = res_path_to_body_part[base_body_path].instantiate()
	var random_color: Color = colors[randi_range(0, len(colors) - 1)]
	(body_type.get_node("body") as CanvasItem).self_modulate = random_color
	
	## pick random face config
	var face_configs: Array[Node] = body_type.get_node("body/face").get_children()
	var face_config: Node = face_configs[randi_range(0, len(face_configs) - 1)]
	
	# place eyes and mouth to body
	pick_part(face_config, "eyes", eye_path, res_path_to_body_part, body_type, true)
	pick_part(face_config, "mouth", mouth_path, res_path_to_body_part, body_type)
	
	if res_path_to_body_part.has(nose_path):
		pick_part(face_config, "nose", nose_path, res_path_to_body_part, body_type)
		
	## pick random limbs config
	var arm_configs: Array[Node] = body_type.get_node("body/limbs/arms").get_children()
	var leg_configs: Array[Node] = body_type.get_node("body/limbs/legs").get_children()
	
	var arm_config = arm_configs[randi_range(0, len(arm_configs) - 1)]
	var leg_config = leg_configs[randi_range(0, len(leg_configs) - 1)]
	
	pick_part(arm_config, ".", arm_path, res_path_to_body_part, body_type, true, true, false)
	pick_part(leg_config, ".", leg_path, res_path_to_body_part, body_type, true, true, false)
	
	## pick random accessories config
	var accessories_configs: Array[Node] = body_type.get_node("body/accessories").get_children()
	var accessory_config: Node = accessories_configs[randi_range(0, len(accessories_configs) - 1)]
	
	if res_path_to_body_part.has(ear_path):
		pick_part(accessory_config, "ears", ear_path, res_path_to_body_part, body_type, true, true, false)

	if res_path_to_body_part.has(horn_path):
		pick_part(accessory_config, "horns", horn_path, res_path_to_body_part, body_type, true, true)
	
	# antenna
	if res_path_to_body_part.has(antenna_path):
		pick_part(accessory_config, "antennaes", antenna_path, res_path_to_body_part, body_type, true, true)
	
	# attach body_type to SubViewport/placeholder
	# body_type.get_node("body").print_tree_pretty()
	subroot.add_child(body_type)


func pick_part(config: Node, node_type: String, res_path: String, res_path_to_body_part: Dictionary, owner: Node, is_flip_enabled: bool = false, can_mirror_x_offset: bool = false, is_z_as_relative: bool = true):
	var body_part_config: Array[Node] = config.get_node(node_type).get_children()
	for node in body_part_config:
		var part: Node = res_path_to_body_part[res_path].instantiate()
		var sprite = (part as Sprite2D)
		
		if not sprite:
			push_error("given res_path %s is not a Sprite2D node" % res_path)
		
		# flip horizontally if left side
		if is_flip_enabled and node.name.contains("_l"):
			sprite.flip_h = true
		
			# Note: when you flip horizontally, the offset position needs to be flipped manually
			# so that when the limb gets parented to the limb Marker2D node, it inherits its parent's transform properties
			if can_mirror_x_offset:
				sprite.offset.x *= -1
				
		# if true, keep z-layering independent of parent-child node relationships
		sprite.z_as_relative = is_z_as_relative

		# Important: must set the mouth node's owner to be the root node; otherwise
		# when packing it into a scene to save, it will not be included
		# https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-method-add-child
		node.add_child(part)
		part.owner = owner

# key - path to resource containing body part (string)
# value - the body part resource (PackedScene)
func load_and_pick_parts() -> Dictionary:
	var paths: PackedStringArray = []
	paths.append_array(required_parts)
	
	### 50% chance to not select a random optional part
	for optional_part in optional_parts:
		if randi() % 2 == 1:
			paths.append(optional_part)
	
	# key - body_part directory path (String)
	# value - random body part picked (String)
	var body_part_to_random_part = {}
	for path in paths:
		var filenames: PackedStringArray = get_filenames(path)
		body_part_to_random_part[path] = filenames[randi_range(0, len(filenames) - 1)]
		#print("%s picked: %s" % [path, body_part_to_random_part[path]])
	
	# load body parts
	var res_path_to_body_part = {}
	for path in paths:
		var body_part: String = body_part_to_random_part[path]
		var part: PackedScene = load("%s/%s" % [path, body_part])
		res_path_to_body_part[path] = part
		
	return res_path_to_body_part

func get_filenames(dir_path: String) -> PackedStringArray:
	var filenames: PackedStringArray = []
	var dir = DirAccess.open(dir_path)
	assert(dir != null and dir.dir_exists(""), "unable to open dir: %s. Ensure folder path exists in FileSystem" % dir_path)
	filenames.append_array(dir.get_files())
	return filenames
