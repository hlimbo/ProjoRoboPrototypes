extends PathFollow2D
class_name Avatar

enum Avatar_Type {
	PARTY_MEMBER,
	ENEMY
}

enum Battle_State {
	WAITING,
	MOVE_SELECTION,
	PENDING_MOVE,
	EXECUTING_MOVE,
	MOVE_CANCELLED,
	# used when receiving damage
	PAUSED,
	KNOCKBACK
}

@export var move_speed: float = 0.1
var _curr_speed: float

@export var texture: Texture2D

@onready var path_follow_2d: PathFollow2D = $"."
@onready var area_2d: Area2D = $Sprite2D/Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var battle_state_label: Label = $BattleStateLabel
@onready var avatar_label: Label = $AvatarLabel
@onready var battle_timers: BattleTimers = $BattleTimers

@onready var ui_layout: UIController = %UILayout


var initial_stats: BaseStats
var curr_stats: BaseStats
var avatar_type: Avatar_Type
var is_alive: bool
# controls whether or not movement along timeline continues on
var resume_motion: bool = true
var battle_state: Battle_State = Battle_State.WAITING

signal on_start_order_step(avatar: Avatar)
signal on_start_exe_step(body: Node2D)

# AI signals
signal on_avatar_flee()
signal on_resume_play(avatar: Avatar)

var battle_manager: BattleManager

# parameter takes in an Avatar ref
var on_turn_end: Callable

func _init() -> void:
	initial_stats = BaseStats.new()
	curr_stats = BaseStats.new()
	is_alive = true
	

func _ready() -> void:
	_curr_speed = move_speed
	sprite_2d.texture = texture
	
	avatar_label.text = self.name
	update_battle_state_text()
	
	area_2d.body_entered.connect(on_area_entered)
	area_2d.body_exited.connect(on_area_exited)
	
	# AI timers
	battle_timers.resume_delay_timer.timeout.connect(on_resume_timeout)
	
	# shared timers
	battle_timers.skill_timer.timeout.connect(on_skill_timeout)
	battle_timers.defense_timer.timeout.connect(on_defend_end)


func _physics_process(delta: float) -> void:
	path_follow_2d.progress_ratio += delta * _curr_speed * float(resume_motion)

func on_area_entered(body: Node2D) -> void:
	battle_state = Battle_State.MOVE_SELECTION
	update_battle_state_text()
	on_start_order_step.emit(self)

func on_area_exited(body: Node2D) -> void:
	on_start_exe_step.emit(body)

#region AI functions
func on_resume_timeout():
	print("on resume timeout %s at time %d " % [self.name, Time.get_ticks_msec()])
	battle_state = Battle_State.WAITING
	update_battle_state_text()
	self.progress_ratio = 0 # reset back to beginning of timeline
	on_resume_play.emit(self)
#endregion

func on_skill_timeout():
	print("on skill timeout called on: %s" % self.name)
	battle_state = Battle_State.WAITING
	update_battle_state_text()
	_curr_speed = move_speed
	progress_ratio = 0
	
	# ai ONLY
	#battle_state = Battle_State.EXECUTING_MOVE
	#update_battle_state_text()

func on_defend_end():
	curr_stats.defense = initial_stats.defense
	
	battle_state = Battle_State.WAITING
	update_battle_state_text()
	
	if on_turn_end:
		on_turn_end.call(self)

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
