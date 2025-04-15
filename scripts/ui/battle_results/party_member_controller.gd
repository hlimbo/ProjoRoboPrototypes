extends Control
class_name PartyMemberController

@export var bot_inventory_systems: BotInventorySystems = BotInventorySystems

var party_member_exp_layout: Resource = preload("res://nodes/ui/battle_results/party_member_exp_layout.tscn")
var party_member_exp_views: Array[PartyMemberExpView] = []

func _ready():
	var avatar_datum: Array[AvatarData] = bot_inventory_systems.get_party_members()
	
	for i in range(len(avatar_datum)):
		var party_member_exp_view: PartyMemberExpView = party_member_exp_layout.instantiate()
		var avatar_data: AvatarData = avatar_datum[i]
		party_member_exp_view.initialize(avatar_data)
		add_child(party_member_exp_view)
		party_member_exp_views.append(party_member_exp_view)
	
func give_experience(exp_earned: float):
	for view in party_member_exp_views:
		view.give_experience(exp_earned)
