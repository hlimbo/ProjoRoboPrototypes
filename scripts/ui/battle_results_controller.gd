extends ColorRect
class_name BattleResultsController

@export var utility_instance: Utility = Utility

@onready var party_member_controller: PartyMemberController = $RootContainer/VBoxContainer/BodyContainer/PartyMemberContainer/VBoxContainer
@onready var item_loot_controller: ItemLootController = $RootContainer/VBoxContainer/BodyContainer/LootDescriptionLayout
@onready var exp_value: Label = $RootContainer/VBoxContainer/TopContainer/BattleResultsContainer/HBoxContainer/ExpValue

func _ready():
	if utility_instance.is_running_on_own_scene(self):
		give_experience_to_party(50)
		generate_loot()

func give_experience_to_party(exp_earned: float):
	exp_value.text = "%d" % exp_earned
	party_member_controller.give_experience(exp_earned)
	
func generate_loot():
	item_loot_controller.generate_loot()
