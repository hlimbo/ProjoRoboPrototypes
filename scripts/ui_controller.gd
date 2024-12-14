extends CanvasLayer

@onready var active_skill_menu: Control = $ActiveSkillMenu
@onready var action_layout: GridContainer = $ActionLayout
@onready var description_panel: Panel = $DescriptionPanel

@onready var attack: Button = $ActionLayout/Attack
@onready var defend: Button = $ActionLayout/Defend
@onready var skill: Button = $ActionLayout/Skills
@onready var flee: Button = $ActionLayout/Flee
@onready var cancel: Button = $ActiveSkillMenu/Cancel

@onready var description_timer: Timer = $DescriptionPanel/Timer
@onready var label: Label = $DescriptionPanel/Label
@onready var active_placeholder_skill: Button = $ActiveSkillMenu/ScrollContainer/VBoxContainer/SkillContainer/ButtonContainer/Button

# Target Menu
@onready var target_menu: PanelContainer = $TargetMenu
@onready var target_label: Label = $TargetMenu/VBoxContainer/TargetLabel
@onready var target_cancel: Button = $TargetMenu/VBoxContainer/Cancel


# Placeholders
@onready var mob1: Area2D = $"../Mob1/Area2D"
@onready var mob2: Area2D = $"../mob2/Area2D"
@onready var mob3: Area2D = $"../mob3/Area2D"

const ON_TARGET_HOVERED: String = "on_target_hovered"
const ON_TARGET_UNHOVERED: String = "on_target_unhovered"
const ON_TARGET_CLICKED: String = "on_target_clicked"

func _ready():
	attack.pressed.connect(_on_attack_button_pressed)
	defend.pressed.connect(_on_defend_button_pressed)
	skill.pressed.connect(_on_skills_button_pressed)
	flee.pressed.connect(_on_flee_button_pressed)
	
	# example of reusing code
	cancel.pressed.connect(_on_cancel_button_pressed)
	target_cancel.pressed.connect(_on_cancel_button_pressed)
	
	active_placeholder_skill.pressed.connect(_on_skill_activated)

	mob1.connect(ON_TARGET_HOVERED, on_target_hovered)
	mob2.connect(ON_TARGET_HOVERED, on_target_hovered)
	mob3.connect(ON_TARGET_HOVERED, on_target_hovered)
	
	mob1.connect(ON_TARGET_UNHOVERED, on_target_unhovered)
	mob2.connect(ON_TARGET_UNHOVERED, on_target_unhovered)
	mob3.connect(ON_TARGET_UNHOVERED, on_target_unhovered)
	
	mob1.connect(ON_TARGET_CLICKED, on_target_clicked)
	mob2.connect(ON_TARGET_CLICKED, on_target_clicked)
	mob3.connect(ON_TARGET_CLICKED, on_target_clicked)
	
func _on_attack_button_pressed():
	action_layout.visible = false
	
	# pick target to attack
	# enable as pickable which accepts mouse pointer events
	mob1.input_pickable = true
	mob2.input_pickable = true
	mob3.input_pickable = true
	
	# switch to attack selection menu
	target_menu.visible = true

func _on_skills_button_pressed():
	active_skill_menu.visible = true
	action_layout.visible = false

func _on_defend_button_pressed():
	# TODOS
	# increase player's defense temporarily for a set time
	# set it back to what it was previously
	description_panel.visible = true
	var player_name := "Mumbo"
	label.text = "%s is defending!" % player_name
	description_timer.start()
	
func _on_cancel_button_pressed():
	target_menu.visible = false
	active_skill_menu.visible = false
	action_layout.visible = true
	
	# disable pickables
	mob1.input_pickable = false
	mob2.input_pickable = false
	mob3.input_pickable = false

func _on_description_timer_timeout():
	target_menu.visible = false
	target_label.text = ""
	
	description_panel.visible = false
	label.text = ""
	
	action_layout.visible = true
	
func _on_skill_activated():
	# TODOs
	# check if enough SRP to cast skill
	# possibly move to SkillContainer and create a skill container script
	description_panel.visible = true
	var player_name := "Mumbo"
	var enemy_name := "Villainous Gelatin"
	var skill_name := active_placeholder_skill.text
	var dmg := randi_range(32, 64)
	label.text = "%s casts %s to %s. It deals %d damage!" % [player_name, skill_name, enemy_name, dmg]
	description_timer.start()

func _on_flee_button_pressed():
	# TODOs
	# - change scene to the overworld scene when successfully fled from battle
	# - figure out a formula that takes difference between your party's avg level
	# and enemies avg level into consideration for when a flee will be successful
	# - if dice roll is less than flee rate, flee is successful, otherwise flee fails
	var flee_rate := 0.5
	var roll = randf()
	description_panel.visible = true
	if roll < flee_rate:
		label.text = "Mumbo Party fled!"
	else:
		label.text = "Mumbo Party cannot escape!"
		
	description_timer.start()

func on_target_hovered(mob_name: String):
	target_label.text = mob_name

func on_target_unhovered():
	target_label.text = ""

func on_target_clicked(mob_name: String):
	# disable pickables
	mob1.input_pickable = false
	mob2.input_pickable = false
	mob3.input_pickable = false
	
	description_panel.visible = true
	var player_name := "Mumbo"
	var dmg := randi_range(1, 20)
	label.text = "%s attacked for %d damage to %s" % [player_name, dmg, mob_name]
	# start timer to hide description panel
	description_timer.start()
