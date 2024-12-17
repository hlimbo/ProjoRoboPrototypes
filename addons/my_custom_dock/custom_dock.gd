@tool
extends EditorPlugin

# A class member to hold the dock during the plugin life cycle
var dock

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	dock = preload("res://addons/my_custom_dock/my_dock.tscn").instantiate()

	# Add the loaded scene to the docks
	add_control_to_dock(DOCK_SLOT_LEFT_UL, dock)
	# NOTE that LEFT_UL means left of the editor, upper-left dock 

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	if dock != null:
		remove_control_from_docks(dock)
		dock.free()
