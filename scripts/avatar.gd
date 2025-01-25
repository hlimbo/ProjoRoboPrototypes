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

# @onready var ui_layout: UIController = %UILayout


var initial_stats: BaseStats
var curr_stats: BaseStats
var avatar_type: Avatar_Type
var is_alive: bool
# controls whether or not movement along timeline continues on
var resume_motion: bool = true
var battle_state: Battle_State = Battle_State.WAITING

signal on_start_order_step(avatar: Avatar)
signal on_start_exe_step(body: Node2D)
signal on_resume_play(avatar: Avatar)
signal on_turn_end(avatar: Avatar)

# AI signals
signal on_avatar_flee()

var battle_manager: BattleManager

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
	_curr_speed = move_speed
	if sprite_2d:
		sprite_2d.texture = texture
	
	avatar_label.text = self.name
	update_battle_state_text()
	
	area_2d.body_entered.connect(on_area_entered)
	area_2d.body_exited.connect(on_area_exited)
	
	battle_timers.skill_timer.timeout.connect(on_skill_timeout)
	battle_timers.defense_timer.timeout.connect(on_defend_end)
	battle_timers.resume_delay_timer.timeout.connect(on_resume_timeout)


func _physics_process(delta: float) -> void:
	path_follow_2d.progress_ratio += delta * _curr_speed * float(resume_motion)

func on_area_entered(_body: Node2D) -> void:
	battle_state = Battle_State.MOVE_SELECTION
	update_battle_state_text()
	on_start_order_step.emit(self)

func on_area_exited(body: Node2D) -> void:
	on_start_exe_step.emit(body)


#region Timer Timeout functions

func on_skill_timeout():
	print("on skill timeout called on: %s" % self.name)

func on_defend_end():
	curr_stats.defense = initial_stats.defense
	on_turn_end.emit(self)

func on_resume_timeout():
	print("on resume timeout %s at time %d " % [self.name, Time.get_ticks_msec()])
	battle_state = Battle_State.WAITING
	update_battle_state_text()
	self.progress_ratio = 0 # reset back to beginning of timeline
	self._curr_speed = move_speed # restore movespeed
	on_resume_play.emit(self)

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
