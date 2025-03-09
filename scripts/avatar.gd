extends PathFollow2D
class_name Avatar

@export var move_speed: float = 0.1
var _curr_speed: float
@export var avatar_data: AvatarData

@export var texture: Texture2D

@onready var path_follow_2d: PathFollow2D = $"."
@onready var area_2d: Area2D = $Sprite2D/Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var battle_state_label: Label = $BattleStateLabel
@onready var avatar_label: Label = $AvatarLabel
@onready var battle_timers: BattleTimers = $BattleTimers

# exporting to view human readable enum strings
@export var avatar_type: Constants.Avatar_Type
@export var is_alive: bool = true
@export var is_knocked_back: bool = false
# controls whether or not movement along timeline continues on
@export var resume_motion: bool = true
# controls movement direction on timeline
@export var is_moving_forward: bool = true
@export var battle_state: Constants.Battle_State = Constants.Battle_State.WAITING
var ui_battle_state_machine: Fsm = Fsm.new()

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

#region Godot callback functions
func _init() -> void:
	is_alive = true
	ui_battle_state_machine.current_state = int(Constants.Battle_State.WAITING)
	ui_battle_state_machine.init_state_map({
		Constants.Battle_State.WAITING: WaitingState.new(self),
		Constants.Battle_State.MOVE_SELECTION: MoveSelectionState.new(self),
		Constants.Battle_State.PENDING_MOVE: PendingMoveState.new(self),
		Constants.Battle_State.EXECUTING_MOVE: ExecutingMoveState.new(self),
		Constants.Battle_State.PAUSED: PausedState.new(self),
		Constants.Battle_State.KNOCKBACK: UiKnockbackState.new(self),
	})
	

func _ready() -> void:
	print("avatar ready called: %s" % name)
	_curr_speed = move_speed
	if sprite_2d:
		sprite_2d.texture = texture
	
	add_child(ui_battle_state_machine)
	avatar_label.text = self.name
	update_battle_state_text()
	
	battle_timers.skill_timer.timeout.connect(on_skill_timeout)
	battle_timers.resume_delay_timer.timeout.connect(on_resume_timeout)
	area_2d.body_entered.connect(on_area_entered)


func _physics_process(delta: float) -> void:
	var delta_move: float = _curr_speed * delta * int(resume_motion) * (1 if is_moving_forward else -1)
	path_follow_2d.progress_ratio += delta_move

func _process(delta: float) -> void:
	update_battle_state_text()

#endregion

func on_area_entered(_body: Node2D) -> void:
	battle_state = Constants.Battle_State.MOVE_SELECTION
	on_start_turn.emit()

func construct(avatar_data: AvatarData):
	avatar_type = avatar_data.avatar_type
	self.avatar_data = avatar_data

#region Timer Timeout functions

func on_skill_timeout():
	print("on skill timeout called on: %s" % self.name)

func on_resume_timeout():
	print("on resume timeout %s at time %d " % [self.name, Time.get_ticks_msec()])
	
	# if pending move is NOT cancelled, reset progress back to 0
	# why? to ensure avatar does not jump back to beginning of timeline if being knocked back
	if not is_knocked_back or progress_ratio == 1:
		self.progress_ratio = 0 # reset back to beginning of timeline
	
	self._curr_speed = move_speed # restore movespeed
	
	battle_state = Constants.Battle_State.WAITING
	ui_battle_state_machine.transition_to(Constants.Battle_State.WAITING)
	BattleSignals.on_resume_play.emit()
#endregion

#region Debug functions

func update_battle_state_text():
	match ui_battle_state_machine.current_state:
		Constants.Battle_State.WAITING:
			battle_state_label.text = "WAITING"
		Constants.Battle_State.MOVE_SELECTION:
			battle_state_label.text = "MOVE_SELECTION"
		Constants.Battle_State.PENDING_MOVE:
			battle_state_label.text = "PENDING_MOVE"
		Constants.Battle_State.EXECUTING_MOVE:
			battle_state_label.text = "EXECUTING_MOVE"
		Constants.Battle_State.MOVE_CANCELLED:
			battle_state_label.text = "MOVE_CANCELLED"
		Constants.Battle_State.PAUSED:
			battle_state_label.text = "PAUSED"
		Constants.Battle_State.KNOCKBACK:
			battle_state_label.text = "KNOCKBACK"
			
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
	
func on_interrupt_motion(interruptee: Avatar, new_battle_state: Constants.Battle_State):
	var old_battle_state: Constants.Battle_State = interruptee.battle_state
	interruptee.battle_state = new_battle_state
	interruptee.ui_battle_state_machine.transition_to(new_battle_state)
	
func pause_motion_for(seconds_to_pause: float, old_battle_state: Constants.Battle_State):
	var process_on_physics_tick: bool = true
	# TODO: may need different levels of "pausing"
	# one where the pause happens when party member is picking an action and another when a skill is being used
	var pause_timer: SceneTreeTimer = get_tree().create_timer(seconds_to_pause, true, process_on_physics_tick)
	toggle_motion(true)
	
	var on_restore_motion = func():
		toggle_motion(false)
		battle_state = old_battle_state
		ui_battle_state_machine.transition_to(old_battle_state)
	
	pause_timer.timeout.connect(on_restore_motion)

# push_back_amount must be a value between 0 and 1.0
func push_back_progress(push_back_amount: float, duration_sec: float):
	toggle_motion(true)
	is_knocked_back = true
	# disable monitoring so that it does not trigger a start turn signal event
	area_2d.monitoring = false
	is_moving_forward = false
	
	# instead of tweening this can be put in a ui knockback state's on_physics_update
	# where it checks when it can exit out of the state
	# TODO(Polish): knockback visually doesn't look quite right... maybe use a different easing function or use the _physics_process() loop to move avatar along path
	var knockback_tween: Tween = create_tween()
	knockback_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	var final_avatar_progress_ratio: float = maxf(progress_ratio - push_back_amount, 0.0)
	knockback_tween.tween_property(self, "progress_ratio", final_avatar_progress_ratio, duration_sec).from_current().set_ease(Tween.EASE_OUT)
	
	var on_finished = func():
		battle_state = Constants.Battle_State.WAITING
		ui_battle_state_machine.transition_to(Constants.Battle_State.WAITING)
		is_knocked_back = false
		# re-enable this so avatar can start their turn -- assuming you get pushed out of the exe rectangle
		area_2d.monitoring = true
		# assuming avatar gets pushed out of pending move or starting turn... reset movement speed back to waiting speed
		_curr_speed = move_speed
	
	knockback_tween.finished.connect(on_finished)
	knockback_tween.play()

func enable():
	visible = true
	set_process(true)
	set_physics_process(true)
	toggle_motion(false)
	ui_battle_state_machine.enable()

func disable():
	visible = false
	set_process(false)
	set_physics_process(false)
	toggle_motion(true)
	ui_battle_state_machine.disable()
