@tool
extends EditorPlugin

# Custom Dock references that show up when enabling the plugin via Project -> Project Settings -> Plugins
var dock: Node
var sprite_sheet_path: LineEdit
var xml_path: LineEdit
var output_path: LineEdit

class SubTexture:
	var name: String
	# measured in pixels
	var position: Vector2
	var width: float
	var height: float


func _enter_tree() -> void:
	dock = preload("res://addons/kenney_xml_sprite_extractor/sprite_extractor_dock.tscn").instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UL, dock)

	# locate spritesheet path, xml path, and output path from dock
	sprite_sheet_path = dock.get_node("VBoxContainer/HBoxContainer/sprite_sheet_path")
	xml_path = dock.get_node("VBoxContainer/HBoxContainer2/xml_path")
	output_path = dock.get_node("VBoxContainer/HBoxContainer3/output_path")
	
	var generate_btn: Button = dock.get_node("VBoxContainer/Button")
	generate_btn.pressed.connect(on_generate_pressed)


# TODO: handle empty string and errors later
func on_generate_pressed():
	var parser = XMLParser.new()
	parser.open(xml_path.text)
	
	# goes line by line to read the xml file until end of file
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			var node_name = parser.get_node_name()
			
			match node_name:
				"SubTexture":
					var subtexture: SubTexture = extract_attributes(parser)
					print("creating %s to be saved in %s" % [subtexture.name, output_path.text])
					var sprite2d: Sprite2D = create_sprite2d_node(subtexture)
					save_sprite2d_scene(sprite2d)
					
# obtain x,y, width, and height properties from xml sheet
func extract_attributes(parser: XMLParser) -> SubTexture:
	var attributes_dict = {}
	for idx in range(parser.get_attribute_count()):
		attributes_dict[parser.get_attribute_name(idx)] = parser.get_attribute_value(idx)
	
	var subtexture = SubTexture.new()
	subtexture.name = attributes_dict["name"].replace(".png", "")
	subtexture.width = float(attributes_dict["width"])
	subtexture.height = float(attributes_dict["height"])
	subtexture.position = Vector2(float(attributes_dict["x"]), float(attributes_dict["y"]))
	
	return subtexture

func create_sprite2d_node(subtexture: SubTexture) -> Sprite2D:
	var sprite2d = Sprite2D.new()
	# res://assets/kenney_monster_pack/spritesheet_default.png
	var texture2d_src: Texture2D = load("%s" % sprite_sheet_path.text)
	sprite2d.name = subtexture.name
	sprite2d.set_texture(texture2d_src)
	# enabled to grab subtexture from src texture
	sprite2d.region_enabled = true
	sprite2d.region_rect.position.x = subtexture.position.x
	sprite2d.region_rect.position.y = subtexture.position.y
	sprite2d.region_rect.size.x = subtexture.width
	sprite2d.region_rect.size.y = subtexture.height
	
	return sprite2d

func save_sprite2d_scene(node: Sprite2D):
	var scene = PackedScene.new()
	scene.pack(node)
	ResourceSaver.save(scene, "%s/%s.tscn" % [output_path.text, node.name])

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	if dock != null:
		remove_control_from_docks(dock)
		dock.free()
	
