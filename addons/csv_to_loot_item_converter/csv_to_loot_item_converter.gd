@tool
extends EditorPlugin

# represents the plugin's view - built like any other node using the scene hierarchy and 2D/3D view
const MainScreen = preload("res://addons/csv_to_loot_item_converter/main_screen.tscn")
var main_screen_instance: Node

## Node View References ##
var file_dialog: FileDialog
var file_path: LineEdit
var find_btn: Button
var convert_btn: Button
var save_directory_path: LineEdit
var open_btn: Button
var save_file_dialog: FileDialog

func _enter_tree() -> void:
	if MainScreen.can_instantiate():
		main_screen_instance = MainScreen.instantiate()
		# Add main screen to editor's main viewport
		EditorInterface.get_editor_main_screen().add_child(main_screen_instance)
		# hide the main screen panel to prevent it from overlapping with the current view when
		# enabling for the first time
		_make_visible(false)
		init_nodes()
	else:
		push_error("Unable to instantiatee Main Screen Instance for Csv to Loot Item Converter")

func _exit_tree() -> void:
	var is_valid: bool = is_instance_valid(main_screen_instance) and !main_screen_instance.is_queued_for_deletion() 
	if is_valid:
		main_screen_instance.queue_free()

# tells plugin to add a new center view in the editor
func _has_main_screen() -> bool:
	return true
	
func _make_visible(visible: bool) -> void:
	if is_instance_valid(main_screen_instance):
		main_screen_instance.visible = visible
	
func _get_plugin_name():
	return "CSV to Loot Item Converter"
	
func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")

func init_nodes():
	file_dialog = main_screen_instance.get_node("HBoxContainer/FileDialog")
	find_btn = main_screen_instance.get_node("HBoxContainer/FindButton")
	file_path = main_screen_instance.get_node("HBoxContainer/LineEdit")
	convert_btn = main_screen_instance.get_node("ConvertButton")
	save_directory_path = main_screen_instance.get_node("HBoxContainer2/LineEdit")
	open_btn = main_screen_instance.get_node("HBoxContainer2/Button")
	save_file_dialog = main_screen_instance.get_node("HBoxContainer2/FileDialog")
	
	find_btn.pressed.connect(on_find_file_pressed)
	open_btn.pressed.connect(on_open_dir_pressed)
	file_dialog.file_selected.connect(on_file_selected)
	save_file_dialog.dir_selected.connect(on_dir_selected)
	convert_btn.pressed.connect(on_convert_pressed)
	
	# specifies which files can be opened
	file_dialog.filters = ["*.txt,*.csv;CSV/Spreadsheet Files"]

func on_find_file_pressed():
	file_dialog.visible = true
	file_dialog.popup_centered_ratio()

func on_open_dir_pressed():
	save_file_dialog.visible = true
	save_file_dialog.popup_centered_ratio()

func on_file_selected(path: String):
	file_path.text = path

func on_dir_selected(path: String):
	save_directory_path.text = path

func on_convert_pressed():
	var csv_file = FileAccess.open(file_path.text,FileAccess.READ)
	var is_first_row: bool = true
	var items: Array[LootItem] = []
	while csv_file.get_position() < csv_file.get_length():
		var line: PackedStringArray = csv_file.get_csv_line("\t")
		
		# skip first row assuming it is a title row
		if is_first_row:
			is_first_row = false
			continue
			
		var loot_item: LootItem = on_convert(line)
		items.append(loot_item)
	
	var start_time = Time.get_ticks_msec()
	for item in items:
		var item_name: String = "%s.tres" % item.item_name.to_snake_case()
		var save_path: String = "%s/%s" % [save_directory_path.text, item_name]
		# slow process... too bad there is no built in batch saving function
		var error = ResourceSaver.save(item, save_path)
		if error != OK:
			push_error("Something went wrong with saving %s with error code: %d" % [item_name, error])
		else:
			print_rich("[color=green]Successfully saved %s[/color]" % save_path)

	var elapsed_time = Time.get_ticks_msec() - start_time
	print("Elapsed time: ", elapsed_time)

func on_convert(items: PackedStringArray) -> LootItem:
	assert(len(items) == 3, "Unable to run on_convert function, check csv file and ensure it has 3 columns")
	
	var loot_item = LootItem.new()
	loot_item.item_name = String(items[0])
	loot_item.rarity = int(items[1])
	loot_item.description = String(items[2])
	
	return loot_item
