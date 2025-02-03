extends PathFollow2D
class_name Avatar

@export var move_speed: float = 0.1
var _curr_speed: float

@export var texture: Texture2D

@onready var path_follow_2d: PathFollow2D = $"."
@onready var area_2d: Area2D = $Sprite2D/Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var battle_state_label: Label = $BattleStateLabel
@onready var avatar_label: Label = $AvatarLabel
@onready var battle_timers: BattleTimers = $BattleTimers

# type aliasing for convenience
const Avatar_Type = Constants.Avatar_Type
const Battle_State = Constants.Battle_State

var initial_stats: BaseStats
var curr_stats: BaseStats
# exporting to view human readable enum strings
@export var avatar_type: Avatar_Type
@export var is_alive: bool = true
# controls whether or not movement along timeline continues on
var resume_motion: bool = true
var battle_state: Battle_State = Battle_State.WAITING

# AI signals
signal on_avatar_flee()

signal on_start_turn
signal on_interrupt(interruptee: Avatar)

# names generated from https://www.fantasynamegenerators.com/bleach-shinigami-names.php
const random_names: PackedStringArray = [
	"Konuragi Tenji",
	"Iekibe Katane",
	"Kiba Baishiro",
	"Ikkahoshi Daimane",
	"Takazawa Watsugu",
	"Umeshita Jomiho",
	"Ozumi Saiyuko",
	"Hitsuka Ezami",
	"Kuroyashi Naokira",
	"Narise Hora",
]


func _init() -> void:
	initial_stats = BaseStats.new()
	curr_stats = BaseStats.new()
	is_alive = true
	

func _ready() -> void:
	print("avatar ready called: %s" % name)
	_curr_speed = move_speed
	if sprite_2d:
		sprite_2d.texture = texture
	
	avatar_label.text = self.name
	update_battle_state_text()
	
	battle_timers.skill_timer.timeout.connect(on_skill_timeout)
	battle_timers.resume_delay_timer.timeout.connect(on_resume_timeout)
	area_2d.body_entered.connect(on_area_entered)


func _physics_process(delta: float) -> void:
	path_follow_2d.progress_ratio += delta * _curr_speed * float(resume_motion)

func _process(delta: float) -> void:
	update_battle_state_text()

func on_area_entered(_body: Node2D) -> void:
	battle_state = Battle_State.MOVE_SELECTION
	on_start_turn.emit()

func connect_on_area_entered():
	area_2d.body_entered.connect(on_area_entered)

#region Timer Timeout functions

func on_skill_timeout():
	print("on skill timeout called on: %s" % self.name)

func on_resume_timeout():
	print("on resume timeout %s at time %d " % [self.name, Time.get_ticks_msec()])
	battle_state = Battle_State.WAITING
	self.progress_ratio = 0 # reset back to beginning of timeline
	self._curr_speed = move_speed # restore movespeed
	BattleSignals.on_resume_play.emit()

#endregion

#region Debug functions

func update_battle_state_text():
	match battle_state:
		Battle_State.WAITING:
			battle_state_label.text = "WAITING"
		Battle_State.MOVE_SELECTION:
			battle_state_label.text = "MOVE_SELECTION"
		Battle_State.PENDING_MOVE:
			battle_state_label.text = "PENDING_MOVE"
		Battle_State.EXECUTING_MOVE:
			battle_state_label.text = "EXECUTING_MOVE"
		Battle_State.MOVE_CANCELLED:
			battle_state_label.text = "MOVE_CANCELLED"
		Battle_State.PAUSED:
			battle_state_label.text = "PAUSED"
		Battle_State.KNOCKBACK:
			battle_state_label.text = "KNOCKBACK"
			
func generate_random_stats() -> void:
	initial_stats.name = random_names[randi_range(0, len(random_names) - 1)]
	initial_stats.attack = randi_range(20,25)
	initial_stats.defense = randi_range(10,15)
	initial_stats.hp = randi_range(40, 80)
	initial_stats.speed = randi_range(10, 20)
	initial_stats.skill_points = 100
	
	curr_stats.set_stats(initial_stats)

#endregion


# wait_time measured in seconds
func calculate_action_execution_speed(wait_time: float) -> float:
	# compute skill exec speed 
	# numerator is the difference b/w the progress_ratios ranging between 0 and 1 inclusive
	# denominator is the time period that the skill will take to execute measured in seconds
	# delay skill until avatar progress ratio reaches 1
	var diff: float = 1 - self.progress_ratio
	var action_exec_time: float = diff / wait_time
	return action_exec_time


func toggle_motion(is_paused: bool):
	resume_motion = !is_paused
	battle_timers.toggle_timers(is_paused)
	
func on_interrupt_motion(interruptee: Avatar, old_battle_state: Constants.Battle_State):
	if interruptee.battle_state == Constants.Battle_State.PAUSED:
		var seconds_to_pause: float = 3
		interruptee.pause_motion_for(seconds_to_pause, old_battle_state)
	elif interruptee.battle_state == Constants.Battle_State.KNOCKBACK:
		var push_back_amount: float = 0.25
		var duration_sec: float = 1
		interruptee.push_back_progress(push_back_amount, duration_sec)
	else:
		print_rich("[color=yellow]avatar %s was neither paused or knocked back[/color]" % curr_stats.name)
		
func pause_motion_for(seconds_to_pause: float, old_battle_state: Constants.Battle_State):
	var process_on_physics_tick: bool = true
	# TODO: may need different levels of "pausing"
	# one where the pause happens when party member is picking an action and another when a skill is being used
	var pause_timer: SceneTreeTimer = get_tree().create_timer(seconds_to_pause, true, process_on_physics_tick)
	resume_motion = false
	
	var on_restore_motion = func():
		print("resuming avatar motion for ", curr_stats.name)
		resume_motion = true
		battle_state = old_battle_state
	
	pause_timer.timeout.connect(on_restore_motion)

# push_back_amount must be a value between 0 and 1.0
func push_back_progress(push_back_amount: float, duration_sec: float):
	resume_motion = false
	
	var knockback_tween: Tween = create_tween()
	knockback_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	var final_avatar_progress_ratio: float = maxf(progress_ratio - push_back_amount, 0.0)
	knockback_tween.tween_property(self, "progress_ratio", final_avatar_progress_ratio, duration_sec)
	
	var on_finished = func():
		print("finished pushback on ", curr_stats.name)
		battle_state = Constants.Battle_State.WAITING
		resume_motion = true
	
	knockback_tween.finished.connect(on_finished)
	knockback_tween.play()
