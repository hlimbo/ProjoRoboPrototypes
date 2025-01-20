# ChatGPT generated code on 1-20-2025
# made some modifications for it to run the code properly

extends Node2D

@onready var light_source: ColorRect = $LightSource

# Position of the light source
var WIDTH = 1280
var HEIGHT = 720
var light_position: Vector2 #= Vector2(WIDTH / 2, HEIGHT / 2) #Vector2(500, 500)

# Shadow length multiplier
@export var shadow_length: float = 100

@export var dir: float = 1
@export var move_speed: float

# Rectangle definitions (array of positions and sizes)
var rectangles = [
	{ "position": Vector2(100, 200), "size": Vector2(50, 50), "color": Color(0.3, 0.7, 1.0) },
	{ "position": Vector2(300, 150), "size": Vector2(50, 50), "color": Color(0.3, 0.7, 1.0) }
]

# Shadow color
var shadow_color: Color = Color(0, 0, 0, 0.5)

func _ready():
	light_source.position = Vector2(WIDTH / 2, HEIGHT / 2)
	light_position = light_source.position

func _draw():
	# Draw each rectangle and its shadow
	for rect in rectangles:
		var position = rect["position"]
		var size = rect["size"]
		var color = rect["color"]
		
		# Calculate rectangle vertices
		var vertices = [
			position,                                # Top-left
			position + Vector2(size.x, 0),          # Top-right
			position + size,                        # Bottom-right
			position + Vector2(0, size.y)           # Bottom-left
		]
		
		# rectangle corner normals
		var normals = [
			Vector2(-1, -1), # Top-left
			Vector2(1, -1), # Top-right
			Vector2(1, 1), # Bottom-right
			Vector2(-1, 1), # Bottom-left
		]
		
		## sides
		#var normals = [
			#Vector2(-1, 0), # left
			#Vector2(0, -1), # top
			#Vector2(1, 0), # right
			#Vector2(0, 1), # bot
		#]
		
		# Calculate shadow vertices
		var shadow_vertices = []
		for i in range(len(vertices)):
			var vertex = vertices[i]
			
			var direction = vertex - light_position
			var normalized_dir = direction.normalized()
			# this draws shadows as one pixel black outline
			shadow_vertices.append(vertex + normalized_dir)
			
			# this draws a skewed rectangle shadow
			#shadow_vertices.append(vertex + normalized_dir * size.length() * shadow_length)
			
		
		var sort_asc = func(a, b):
			if a.x == b.x:
				return a.y < b.y
			return a.x < b.x
			
		var sort_desc = func(a, b):
			if a.x == b.x:
				return a.y > b.y
			return a.x > b.x
		
		var start_verts = shadow_vertices
		
		var end_verts = []
		for i in range(len(start_verts)):
			var v = start_verts[i]
			var normal = normals[i]
			var direction = v - light_position
			var unit_dir = direction.normalized()
			var dot_value = normal.dot(unit_dir)
			# add shadow end point if dot between normal and direction >= 0
			if dot_value >= 0:
				end_verts.append(v + unit_dir * shadow_length)
		
		# Sort here because if any of the vertices cross over the shadow polygon won't be drawn
		## Problem I ran into is that the polygon wasn't being drawn
		## as the order of the vertices mattered when passed into draw_polygon
		## See: https://www.reddit.com/r/godot/comments/9ycloo/bad_polygon_why_cant_i_draw_a_polygon_for_these/
		# ascending
		start_verts.sort_custom(sort_asc)
		
		# descending
		end_verts.sort_custom(sort_desc)
		
		shadow_vertices.append_array(end_verts)
		
		# Draw shadow polygon
		draw_polygon(shadow_vertices, [shadow_color])
		
		# Draws shadow rays to visualize shadow direction
		#draw_multiline(shadow_vertices, shadow_color, 5)
				
		# Draw rectangle on top
		draw_rect(Rect2(position, size), color)
		
		# Light Source
		draw_circle(light_position, 5, Color.WHITE)
		
		### Debugging Shadow
		#for v in shadow_vertices:
			#draw_circle(v, 5, Color.RED)
			#
		#draw_polyline(shadow_vertices, Color.GREEN, 5)

var x_input_dir = 0
var y_input_dir = 0

func _process(delta: float) -> void:
	if Input.is_action_pressed("up"):
		y_input_dir = -1
	elif Input.is_action_pressed("down"):
		y_input_dir = 1
	else:
		y_input_dir = 0
		
	if Input.is_action_pressed("left"):
		x_input_dir = -1
	elif Input.is_action_pressed("right"):
		x_input_dir = 1
	else:
		x_input_dir = 0
		
	var input_unit_dir = Vector2(x_input_dir, y_input_dir).normalized()
	light_source.position += input_unit_dir * 500 * delta
	
	light_position = light_source.position
	
	## move rectangle side to side
	#for rect in rectangles:
		#rect.position.x += dir * move_speed * delta
		#if rect.position.x > 1000 or rect.position.x < 100:
			#dir *= -1
	
	queue_redraw()
