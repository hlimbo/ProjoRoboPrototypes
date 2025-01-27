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

# @onready var ui_layout: UIController = %UILayout

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

#var battle_manager: BattleManager

# TODO - find a way to remove circular reference
# circular reference between actor and avatar
# this is needed for now to integrate command pattern here...
var actor: WeakRef

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
	battle_timers.defense_timer.timeout.connect(on_defend_end)
	battle_timers.resume_delay_timer.timeout.connect(on_resume_timeout)
	
	area_2d.body_entered.connect(on_area_entered)


func _physics_process(delta: float) -> void:
	path_follow_2d.progress_ratio += delta * _curr_speed * float(resume_motion)

func on_area_entered(_body: Node2D) -> void:
	battle_state = Battle_State.MOVE_SELECTION
	update_battle_state_text()
	if actor.get_ref():
		BattleSignals.on_start_turn.emit(actor.get_ref())
	
#region Timer Timeout functions

func on_skill_timeout():
	print("on skill timeout called on: %s" % self.name)

func on_defend_end():
	curr_stats.defense = initial_stats.defense
	BattleSignals.on_end_turn.emit(self)

func on_resume_timeout():
	print("on resume timeout %s at time %d " % [self.name, Time.get_ticks_msec()])
	battle_state = Battle_State.WAITING
	update_battle_state_text()
	self.progress_ratio = 0 # reset back to beginning of timeline
	self._curr_speed = move_speed # restore movespeed
	if actor.get_ref():
		BattleSignals.on_resume_play.emit(actor.get_ref())

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
