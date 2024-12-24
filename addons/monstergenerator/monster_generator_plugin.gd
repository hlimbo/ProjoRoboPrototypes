@tool
extends EditorPlugin


const resource_path: String = "res://addons/monstergenerator/monster_generator_view.tscn"
const toggle_mob_gen_dock_label: String = "Toggle MobGen Dock"
var dock_resource: Resource
var dock: Control
var is_dock_visible: bool

# add plugin view to top left of godot editor
# this happens when you toggle the plugin as on in Project -> Project Settings -> Plugin
func _enter_tree() -> void:
	dock_resource = preload(resource_path)
	if dock_resource.can_instantiate():
		is_dock_visible = true
		dock = dock_resource.instantiate()
		dock.hidden.connect(on_close_dock)
		add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BL, dock)
		add_tool_menu_item(toggle_mob_gen_dock_label, on_toggle_mob_gen_dock)
	else:
		push_error("Unable to preload %s" % resource_path)

# remove dock when this node exits the scene tree
# this happens when you toggle the plugin as off in Project -> Project Settings -> Plugin
func _exit_tree() -> void:
	if dock_resource and dock:
		is_dock_visible = false
		remove_tool_menu_item(toggle_mob_gen_dock_label)
		remove_control_from_docks(dock)
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
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BL, dock)
	is_dock_visible = true	
