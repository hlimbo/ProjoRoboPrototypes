extends Node
class_name PartyMemberExpView

@onready var party_member_portrait: TextureRect = $HBoxContainer/PartyMemberPortrait
@onready var name_label: Label = $HBoxContainer/StatContainer/NameLevelContainer/NameLabel
@onready var level_label: Label = $HBoxContainer/StatContainer/NameLevelContainer/LevelLabel
@onready var curr_exp_label: Label = $HBoxContainer/StatContainer/ExpContainer/ExpText/ExpNumbers/CurrExp
@onready var max_exp_label: Label = $HBoxContainer/StatContainer/ExpContainer/ExpText/ExpNumbers/MaxExp
@onready var exp_bar: ProgressBar = $HBoxContainer/StatContainer/ExpContainer/ExpBar

# Debugging utility
@onready var button: Button = $HBoxContainer/StatContainer/ExpContainer/Button
var can_start: bool = false

# TODO: load from a model AND respect model's final calculations
# calculations done here are for animation purposes only and may
# be off due to floating point inprecision
@export var avatar_image: Texture
@export var avatar_name: String
@export var level: int
@export var curr_exp: float
# TODO: use a table to look up what the next max is if a level up event occurs
@export var max_exp_per_level: float
# amount of time it takes to apply all exp points measured in seconds
@export var exp_gain_time: float = 0.15

# Test variable
@export var total_exp_earned: float

# needed because curr_exp can start anywhere between 0 and 100 exclusive
var start_exp: float = 0
# used to apply exp when multiple levels are reached
var remaining_exp: float = 0
var exp_earned_per_level: float = 0
var levels_earned: int = 0

var curr_time: float = 0
var time_left: float = 0

var start_tick: float = 0
const MSEC_TO_SEC = 1000

func _ready() -> void:
	party_member_portrait.texture = avatar_image
	name_label.text = avatar_name
	level_label.text = "lvl %d" % level
	curr_exp_label.text = "%d" % int(curr_exp)
	max_exp_label.text = "%d" % int(max_exp_per_level)
	exp_bar.value = (curr_exp / max_exp_per_level) * 100
	
	button.pressed.connect(on_pressed)

func on_pressed():
	start_tick = Time.get_ticks_msec()
	curr_time = 0
	time_left = exp_gain_time
	
	# check for overflow - level up
	remaining_exp = total_exp_earned
	start_exp = curr_exp
	var total_exp = curr_exp + total_exp_earned
	levels_earned = int(total_exp / max_exp_per_level)
	# subtract by start_exp because party member can have exp > 0
	# computing the difference here gives us how much more exp they need
	# to level up - ensure curr_exp < max_exp_per_level otherwise it will break
	exp_earned_per_level = min(total_exp_earned, max_exp_per_level - start_exp)

	can_start = true

# not controlled by an upper bound of delay time
func _process(delta: float) -> void:
	if not can_start:
		return
	
	# stop when no more exp to apply
	if remaining_exp <= 0:
		return
		
	## stop when all exp applied and not leveling up
	if curr_exp == start_exp + exp_earned_per_level:
		remaining_exp = 0
		var time_taken = Time.get_ticks_msec() - start_tick
		start_tick = Time.get_ticks_msec()
		print("it took %f secs leftover" % (float(time_taken) / MSEC_TO_SEC))
		return

	var level_increase = 0
	
	# this calculates proportionally how long it takes for exp to reach a new level
	var exp_per_time = (exp_earned_per_level/ max(1, remaining_exp)) * exp_gain_time

	# exp earned per frame
	var delta_exp = (exp_earned_per_level / exp_per_time) * delta 
	curr_exp = min(curr_exp + delta_exp, start_exp + exp_earned_per_level)
	
	# level up
	if curr_exp == max_exp_per_level:
		var time_taken = Time.get_ticks_msec() - start_tick
		start_tick = Time.get_ticks_msec()
		print("it took %f secs" % (float(time_taken) / MSEC_TO_SEC))
		
		level_increase = 1
		curr_exp = 0
		start_exp = curr_exp
		# recompute remaining exp left and amount of exp to award for next level
		remaining_exp = max(remaining_exp - exp_earned_per_level, 0)
		exp_earned_per_level = min(remaining_exp, max_exp_per_level)
	
	level += level_increase
	
	# update UI
	level_label.text = "lvl %d" % level
	curr_exp_label.text = "%d" % int(curr_exp)
	exp_bar.value = (curr_exp / max_exp_per_level) * exp_bar.max_value
