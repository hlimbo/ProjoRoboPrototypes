extends Control
class_name PartyMemberController

@export var utility_instance: Utility
var party_member_exp_layout: Resource = preload("res://nodes/ui/party_member_exp_layout.tscn")
var party_member_exp_views: Array[PartyMemberExpView] = []

func init_dependencies():
	utility_instance = Utility

func _ready():
	init_dependencies()
	
	var resources: Array[Resource] = utility_instance.load_resources_from_folder("res://resources/avatar")
	var avatar_datum: Array[AvatarData]
	for res in resources:
		avatar_datum.append(res as AvatarData)
	
	for i in range(len(avatar_datum)):
		var party_member_exp_view: PartyMemberExpView = party_member_exp_layout.instantiate()
		var avatar_data: AvatarData = avatar_datum[i]
		party_member_exp_view.initialize(avatar_data)
		add_child(party_member_exp_view)
		party_member_exp_views.append(party_member_exp_view)
	
func give_experience(exp_earned: float):
	for view in party_member_exp_views:
		view.give_experience(exp_earned)
