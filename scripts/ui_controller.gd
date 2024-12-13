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

func _ready():
	attack.pressed.connect(_on_attack_button_pressed)
	defend.pressed.connect(_on_defend_button_pressed)
	skill.pressed.connect(_on_skills_button_pressed)
	flee.pressed.connect(_on_flee_button_pressed)
	cancel.pressed.connect(_on_cancel_button_pressed)
	
	active_placeholder_skill.pressed.connect(_on_skill_activated)
		
func _on_attack_button_pressed():
	# TODOs
	# pick target to attack
	
	description_panel.visible = true
	
	# apply attack damage
	var player_name := "Mumbo"
	var enemy_name := "Villainous Gelatin"
	var dmg := randi_range(1, 20)
	label.text = "%s attacked for %d damage to %s" % [player_name, dmg, enemy_name]
	# start timer to hide description panel
	description_timer.start()

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
	active_skill_menu.visible = false
	action_layout.visible = true

func _on_description_timer_timeout():
	description_panel.visible = false
	label.text = ""
	
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
