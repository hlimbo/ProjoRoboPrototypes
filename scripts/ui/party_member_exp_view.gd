extends Node
class_name PartyMemberExpView

@onready var party_member_portrait: TextureRect = $HBoxContainer/PartyMemberPortrait
@onready var name_label: Label = $HBoxContainer/StatContainer/NameLevelContainer/NameLabel
@onready var level_label: Label = $HBoxContainer/StatContainer/NameLevelContainer/LevelLabel
@onready var curr_exp_label: Label = $HBoxContainer/StatContainer/ExpContainer/ExpText/ExpNumbers/CurrExp
@onready var max_exp_label: Label = $HBoxContainer/StatContainer/ExpContainer/ExpText/ExpNumbers/MaxExp
@onready var exp_bar: ProgressBar = $HBoxContainer/StatContainer/ExpContainer/ExpBar

@onready var button: Button = $HBoxContainer/StatContainer/ExpContainer/Button
var can_start: bool = false

# TODO: load from a model
@export var avatar_image: Texture
@export var avatar_name: String
@export var level: int
@export var curr_exp: float
# TODO: use a table to look up what the next max is if a level up event occurs
@export var max_exp_per_level: float

# Test variable
@export var exp_earned: float

var exp_earned_per_level: float = 0

var time_delay: float = 0.25 # sec
var curr_time: float
const MS_PER_SEC = 1000

var remaining_exp: int = 0
var levels_earned: int = 0

func _ready() -> void:
	party_member_portrait.texture = avatar_image
	name_label.text = avatar_name
	level_label.text = "lvl %d" % level
	curr_exp_label.text = "%d" % int(curr_exp)
	max_exp_label.text = "%d" % int(max_exp_per_level)
	exp_bar.value = (curr_exp / max_exp_per_level) * 100
	
	button.pressed.connect(on_pressed)

func on_pressed():
	curr_time = 0
	
	# check for overflow - level up
	var results = calc_exp(exp_earned)
	remaining_exp = results[0]
	levels_earned = results[1]
	
	print("levels earned: %d" % levels_earned)
	print("remaining exp: %d" % remaining_exp)
	
	exp_earned_per_level = minf(max_exp_per_level - curr_exp, exp_earned)

	can_start = true

# you can level up as many times as you can assuming exp_earned >= max exp for lvl 1, lvl 2, etc
func calc_exp(xp: int) -> Array:
	var remaining_exp = max(xp - max_exp_per_level, 0)
	
	# temp code since max exp per level will be different level cap per level
	var total_exp = curr_exp + xp
	levels_earned = int(total_exp / max_exp_per_level)
	
	# level += levels_earned
	#if remaining_exp > 0:
		#curr_exp = remaining_exp
	#else:
		#curr_exp = total_exp
		
	return [remaining_exp, levels_earned]

# TODO: animate
func update_view():
	level_label.text = "lvl %d" % level
	curr_exp_label.text = "%d" % int(curr_exp)
	exp_bar.value = int((float(curr_exp) / max_exp_per_level) * 100)

# do we need to count how much exp was earned in total
# and use a separate variable to keep track of how much exp is earned per level?

func _process(delta: float) -> void:
	if not can_start:
		return
	
	# Increment experience over time
	var delta_exp = (exp_earned_per_level / time_delay) * delta
	curr_exp = min(curr_exp + delta_exp, max_exp_per_level)
	curr_exp_label.text = "%d" % int(curr_exp)
	exp_bar.value = (curr_exp / max_exp_per_level) * 100
	curr_time += delta

	# Check if a level-up is triggered
	if curr_exp >= max_exp_per_level:
		# Process a single level-up per frame
		level += 1
		level_label.text = "lvl %d" % level
		curr_exp -= max_exp_per_level  # Deduct max experience for this level
		
		# Recalculate experience for the next level
		exp_earned_per_level = min(max_exp_per_level, remaining_exp)
		
		remaining_exp -= max_exp_per_level  # Reduce remaining experience
		
		if remaining_exp < 0:
			remaining_exp = 0
		
		curr_time = 0  # Reset time for the next animation cycle

	# Ensure no more experience is added when remaining_exp is depleted
	if exp_earned_per_level <= 0:
		curr_exp = 0

	# Update the UI
	curr_exp_label.text = "%d" % int(curr_exp)
	exp_bar.value = (curr_exp / max_exp_per_level) * 100
