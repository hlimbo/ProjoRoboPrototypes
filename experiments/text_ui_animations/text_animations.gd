extends Label
class_name TextAnimPlayer

var tween: Tween

var original_label_position: Vector2
var original_label_scale: Vector2
var original_font_color: Color

func _ready():
	original_label_position = self.position
	original_label_scale = self.scale
	original_font_color = self.theme.get_color("font_color", "Label")
	
func reset():
	self.position = original_label_position
	self.scale = original_label_scale
	self.remove_theme_color_override("font_color")
	self.modulate.a = 0

func kill_tween():
	if tween and (tween.is_valid or tween.is_running):
		tween.kill()
		self.reset()

func play_text_animation(digit: int = 999):
	kill_tween()
	# damage label text -- need to create 2 separate tweens for the damage label one to appear using the modulate alpha value
	# another to move up and hide
	# this is the css of game dev....
	self.text = "%d" % digit
	
	# this modifies the font color of this label node - overrides base theme color
	self.add_theme_color_override("font_color", Color.RED)
	self.add_theme_constant_override("outline_size", 16)
	
	tween = create_tween()
	var final_scale = Vector2(1.25, 1.25)
	var dt2: float = 0.18
	
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1, dt2)
	# setting pivot point is important so it doesn't appear that the label doesn't move
	var prop_tween: PropertyTweener = tween.tween_property(self, "scale", final_scale, dt2)
	
	# move this node up
	var delay_secs: float = 0.35
	var offset: Vector2 = Vector2(0, -100)
	tween.chain().tween_property(self, "position", original_label_position + offset, dt2).set_delay(delay_secs)
	tween.tween_property(self, "modulate:a", 0.0, dt2).set_delay(delay_secs)
	
	## reset back to previous properties when tween finishes
	#tween.finished.connect(func(): 
		#print("tween finished")
		#reset()
	#)

# bounce repetitively
func play_text_animation2(digit: int = 999):
	kill_tween()
	self.text = "%d" % digit
	self.add_theme_constant_override("outline_size", 16)
	
	# text jumps up -- easing function bounce
	tween = create_tween()
	# to create jumping motion the offset needs to approach the y-position of the original_label_position
	var offset = Vector2(0, 100)
	
	# linear
	var iteration_count = 2
	var alpha_duration = 0.1
	var tween_duration: float = 0.05
	
	tween.tween_property(self, "modulate:a", 1.0, alpha_duration)
	while iteration_count > 0:
		# Tween.TRANS_BOUNCE
		tween.tween_property(self, "position", original_label_position - offset, tween_duration).set_trans(Tween.TRANS_SINE).set_delay(0.02)
		tween.tween_property(self, "position", original_label_position, tween_duration).set_trans(Tween.TRANS_SINE).set_delay(0.02)
		# .set_trans(Tween.TRANS_BACK)
		offset.y -= 50
		iteration_count -= 1
	
	tween.tween_property(self, "modulate:a", 1.0, alpha_duration)
	# tween.tween_property(self, "modulate:a", 0.0, alpha_duration).set_delay(0.5)
	#tween.finished.connect(reset)

# bounce once
func play_text_animation3(digit: int = 999, jump_height: float = 100.0):
	kill_tween()
	
	self.add_theme_constant_override("outline_size", 16)
	self.text = "%d" % digit
	self.modulate.a = 1.0
	
	tween = create_tween()
	var offset = Vector2(0.0, jump_height)
	var dur = 0.1
	tween.tween_property(self, "position", original_label_position - offset, dur).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position", original_label_position, dur).set_trans(Tween.TRANS_SINE)
	# add a delay before finishing the tween - set_delay only works for the delaying the LAST tween
	# can't add a delay after the last one
	tween.tween_property(self, "modulate:a", 1.0, 0.2)
	# tween.finished.connect(reset)
	
