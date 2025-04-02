extends Node2D
class_name PunchingBag

# dependencies
@export var camera: ScreenShake

# in degrees
@export var min_rotation: float = -15.0
@export var max_rotation: float = 15.0

@onready var color_rect: ColorRect = $ColorRect
@onready var damage_label: Label = $DamageLabel

var original_label_scale: Vector2
var original_damage_label_position: Vector2
var original_font_color: Color
var original_font_outline_color: Color

func _ready():
	original_label_scale = damage_label.scale
	original_damage_label_position = damage_label.position
	# completely stupid.... why doesn't godot allow me to access theme overrides via . notation??
	# https://www.reddit.com/r/godot/comments/x6l82x/how_to_change_color_of_label_text_via_code/
	original_font_color = Color(damage_label["theme_override_colors/font_color"])
	original_font_outline_color = Color(damage_label["theme_override_colors/font_outline_color"])


func receive_damage(damage_value: int, max_damage: int):
	print("got hit")
	# the higher the number, the more the punching bag oscillates...
	var str_percentage: float = (float(damage_value) / float(max_damage)) 
	damage_label.text = "%d" % damage_value
	var curr_rotation: float = str_percentage * max_rotation
	
	var shake_strength: float = str_percentage * 50
	var shake_duration: float = str_percentage * 0.75 # seconds
	#camera.start_shake(shake_strength, shake_duration)
	
	# flash red on loop for color rect
	var tween: Tween = create_tween().set_loops(8)
	var original_color: Color = color_rect.color
	var dt: float = 0.25 / 4
	tween.tween_property(color_rect, "color", Color.RED, dt).from(original_color)
	tween.tween_property(color_rect, "color", original_color, dt).from(Color.RED)
	# rotate back and forth
	var rotate_tween: Tween = create_tween().set_loops(4)
	var original_rotation = color_rect.rotation
	var min_rotation_rad: float = deg_to_rad(-curr_rotation)
	var max_rotation_rad: float = deg_to_rad(curr_rotation)
	# the order will need to be switched depending on which direction this bag is hit from
	rotate_tween.tween_property(color_rect, "rotation", min_rotation_rad, dt).from(original_rotation)
	rotate_tween.tween_property(color_rect, "rotation", original_rotation, dt).from(min_rotation_rad)
	rotate_tween.tween_property(color_rect, "rotation", max_rotation_rad, dt).from(original_rotation)
	rotate_tween.tween_property(color_rect, "rotation", original_rotation, dt).from(max_rotation_rad)
	
	# damage label text -- need to create 2 separate tweens for the damage label one to appear using the modulate alpha value
	# another to move up and hide
	# this is the css of game dev....
	var label_tween = create_tween()
	var final_scale = Vector2(1.25, 1.25)
	var dt2: float = 0.18
	
	label_tween.set_parallel(true)
	label_tween.tween_property(damage_label, "modulate:a", 1, dt2).from(0)
	label_tween.tween_property(damage_label, "modulate:a", 1, dt2).from(0)
	# setting pivot point is important so it doesn't appear that the label doesn't move
	label_tween.tween_property(damage_label, "scale", final_scale, dt2).from(original_label_scale)
	
	var delay_secs: float = 0.75
	var delay_timer: SceneTreeTimer = get_tree().create_timer(delay_secs)
	delay_timer.timeout.connect(func():
		print("delay timer timed out")
		var label_tween2 = create_tween()
		var offset: Vector2 = Vector2(0, -100)

		label_tween2.set_parallel(true)
		label_tween2.tween_property(damage_label, "theme_override_colors/font_color", Color(original_font_color, 0), dt2).from_current()
		label_tween2.tween_property(damage_label, "theme_override_colors/font_outline_color", Color(original_font_outline_color, 0), dt2).from_current()
		label_tween2.tween_property(damage_label, "position", original_damage_label_position + offset, dt2).from_current()
		
		# reset back to previous properties when tween finishes
		label_tween2.finished.connect(func(): 
			print("tween finished")
			damage_label.position = original_damage_label_position
			damage_label.scale = original_label_scale
			damage_label["theme_override_colors/font_color"] = original_font_color
			damage_label["theme_override_colors/font_outline_color"] = original_font_outline_color
			damage_label.modulate.a = 0
		)
		
	)
	
