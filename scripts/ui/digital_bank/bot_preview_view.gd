extends Control
class_name BotPreviewView

@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport
@export var start_position: Vector2 = Vector2(190, 200)

func add_bot_to_preview(bot_preview: PackedScene):
	assert(is_instance_valid(bot_preview))
	
	var bot: Node2D = bot_preview.instantiate()
	# remove previously loaded bot preview
	var children = sub_viewport.get_children()
	while len(children) > 0:
		var child = children.pop_back()
		child.queue_free()
	
	# Wait 1 frame to free all children
	await Engine.get_main_loop().process_frame
	
	sub_viewport.add_child(bot)
	bot.position = start_position
