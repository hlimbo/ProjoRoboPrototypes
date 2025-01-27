extends Node
class_name BattleManager

const avatar_res_path: String = "res://nodes/battle_timeline/avatar.tscn"
const avatar_res: Resource = preload(avatar_res_path)

const party_member_resources: Array[Resource] = [
	preload("res://nodes/actors/yellow_mob_2.tscn")
]

const enemy_resources: Array[Resource] = [
	preload("res://nodes/actors/enemy_placeholder.tscn")
]

const party_member_textures: Array[Texture2D] = [
	preload("res://assets/kenney_emotes-pack/PNG/Vector/Style 2/emote_stars.png"),
	preload("res://assets/kenney_emotes-pack/PNG/Vector/Style 2/emote_drop.png"),
	preload("res://assets/kenney_emotes-pack/PNG/Vector/Style 2/emote_sleep.png"),
	preload("res://assets/kenney_emotes-pack/PNG/Vector/Style 2/emote_music.png"),
]

enum Encounter_Type {
	NORMAL,
	INITIATIVE,
	AMBUSH,
}

enum Actor_Type {
	PARTY_MEMBER,
	ENEMY,
}

# hardcode encounter type for now
@export var encounter_type: Encounter_Type
@export var enemy_spawn_count: int
@export var party_member_spawn_count: int
@export var enemy_texture: Texture2D

# describes the range where actors can start on the timeline
const starting_timeline_positions = {
	Encounter_Type.NORMAL: {
		Actor_Type.PARTY_MEMBER: [0.25, 0.5],
		Actor_Type.ENEMY: [0.25, 0.5],
	},
	Encounter_Type.INITIATIVE: {
		Actor_Type.PARTY_MEMBER: [0.4, 0.5],
		Actor_Type.ENEMY: [0.25, 0.35],
	},
	Encounter_Type.AMBUSH: {
		Actor_Type.PARTY_MEMBER: [0.25, 0.35],
		Actor_Type.ENEMY: [0.4, 0.5],
	}
}

# names generated from https://www.fantasynamegenerators.com/bleach-shinigami-names.php
const party_member_names: PackedStringArray = [
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

const enemy_names: PackedStringArray = [
	"Noxious L",
	"Giyeruye",
	"Swiper",
	"Zallayur",
	"Mesher",
	"egoll",
	"Lurker",
	"Cleaver",
	"Uyugu",
	"Bouncy S",
]


var party_member_stats: Array[BaseStats]= []
var enemy_stats: Array[BaseStats] = []

var party_member_avatars: Array[Avatar] = []
var enemy_avatars: Array[Avatar] = []

var party_members: Array[Actor] = []
var enemies: Array[Actor] = []

@onready var battle_scene: Node2D = $"../BattleScene"

@onready var starting_party_member_positions: Array[Vector2] = [
	$"../BattleScene/PartyMember1".position,
	# $PartyMember1.position,
	#$PartyMember2.position,
	#$PartyMember3.position,
]

@onready var starting_enemy_positions: Array[Vector2] = [
	$"../BattleScene/Enemy1".position,
	# $Enemy1.position,
	#$Enemy2.position,
	#$Enemy3.position,
]

@onready var one_d_graph: Control = owner.get_node("UILayout/OneDGraph")

var max_battle_speed: int = 0
@export var damage_calculator: IDamageCalculator

func generate_random_stats(actor_type: Actor_Type) -> BaseStats:
	var stats = BaseStats.new()
	
	if actor_type == Actor_Type.PARTY_MEMBER:
		stats.name = party_member_names[randi_range(0, len(party_member_names) - 1)]
	else:
		stats.name = enemy_names[randi_range(0, len(enemy_names) - 1)]
	
	stats.attack = randi_range(20,25)
	stats.defense = randi_range(10,15)
	stats.hp = randi_range(40, 80)
	stats.speed = randi_range(10, 20)
	stats.skill_points = 100

	return stats

func get_starting_timeline_positions() -> Array:
	var party_range = starting_timeline_positions[encounter_type][Actor_Type.PARTY_MEMBER]
	var enemy_range = starting_timeline_positions[encounter_type][Actor_Type.ENEMY]
	return [party_range, enemy_range]
	
func _enter_tree() -> void:
	# initialize battle participants' base stats
	for i in range(0, party_member_spawn_count):
		var stats = generate_random_stats(Actor_Type.PARTY_MEMBER)
		party_member_stats.append(stats)
		max_battle_speed = maxi(max_battle_speed, stats.speed)
	
	for i in range(0, enemy_spawn_count):
		var stats = generate_random_stats(Actor_Type.ENEMY)
		enemy_stats.append(stats)
		max_battle_speed = maxi(max_battle_speed, stats.speed)

func _ready() -> void:
	print("battle manager ready called")
	# load avatars and set random location on path2D
	var party_line: Path2D = one_d_graph.get_node("PartyPath2D")
	var enemy_line: Path2D = one_d_graph.get_node("EnemyPath2D")
	
	for i in range(0, party_member_spawn_count):
		var avatar: Avatar = avatar_res.instantiate()
		avatar.texture = party_member_textures[i]
		avatar.name = party_member_stats[i].name
		avatar.move_speed = (party_member_stats[i].speed / float(max_battle_speed)) * 0.25
		avatar.initial_stats.set_stats(party_member_stats[i])
		avatar.curr_stats.set_stats(party_member_stats[i])
		avatar.avatar_type = Avatar.Avatar_Type.PARTY_MEMBER
		party_line.add_child(avatar)
		party_member_avatars.append(avatar)
		# set owner of this node to be the root node of the scene it is spawned in
		# if not set, godot scene tree won't recognize its existence
		avatar.owner = party_line
		
	for i in range(0, enemy_spawn_count):
		var avatar: Avatar = avatar_res.instantiate()
		avatar.texture = enemy_texture
		avatar.move_speed = (enemy_stats[i].speed / float(max_battle_speed)) * 0.25
		avatar.name = enemy_stats[i].name
		avatar.initial_stats.set_stats(enemy_stats[i])
		avatar.curr_stats.set_stats(enemy_stats[i])
		avatar.avatar_type = Avatar.Avatar_Type.ENEMY
		enemy_line.add_child(avatar)
		enemy_avatars.append(avatar)
		# set owner of this node to be the root node of the scene it is spawned in
		# if not set, godot scene tree won't recognize its existence
		avatar.owner = enemy_line
	
	### Connect Dependencies ... ###
	for i in range(len(party_member_resources)):
		var start_pos: Vector2 = starting_party_member_positions[i]
		var party_member_resource = party_member_resources[i]
		var party_member: Actor = party_member_resource.instantiate()
		
		party_member.owner = self
		party_member.position = start_pos
		
		party_member.avatar = party_member_avatars[i]
		var info_display: InfoDisplay = party_member.get_info_display()
		info_display.avatar = party_member_avatars[i]
		
		damage_calculator.on_damage_received.connect(info_display.on_damage_received)
		party_member.battle_manager = self
		
		party_members.append(party_member)
		# triggers _ready() function to be invoked on the child being added
		battle_scene.add_child(party_member)
	
	for i in range(len(enemy_resources)):
		var start_pos: Vector2 = starting_enemy_positions[i]
		var enemy_resource = enemy_resources[i]
		var enemy: Actor = enemy_resource.instantiate()
		
		enemy.owner = self
		enemy.position = start_pos
		
		# TODO - add BattleParticipant flee back here maybe?
		# (enemy_mobs[i] as BattleParticipant).avatar = enemy_avatars[i]
		enemy.avatar = enemy_avatars[i]
		var info_display: InfoDisplay = enemy.get_info_display()
		info_display.avatar = enemy.avatar
		# Improvement - could re-organize the actor class by creating 2 subclasses party_member and enemy_ai
		var target_selection_area: MobSelection = enemy.get_target_selection_area()
		target_selection_area.actor = enemy
		
		damage_calculator.on_damage_received.connect(info_display.on_damage_received)
		enemy.battle_manager = self
		
		enemies.append(enemy)
		battle_scene.add_child(enemy)
	
	### TODO - figure out how to remove circular references between actor and avatar
	for i in range(len(party_members)):
		var party_actor: Actor = party_members[i]
		var party_avatar: Avatar = party_member_avatars[i]
		party_avatar.actor = weakref(party_actor)
		
	for i in range(len(enemies)):
		var enemy: Actor = enemies[i]
		var enemy_avatar: Avatar = enemy_avatars[i]
		enemy_avatar.actor = weakref(enemy)
	
	
	var ranges = get_starting_timeline_positions()
	print ("encounter type: %d" % encounter_type)
	
	# give random starting locations based on a range
	for party_member in party_member_avatars:
		var start_position = randf_range(ranges[0][0], ranges[0][1])
		print_rich("[color=yellow]progress ratio picked for party avatar is %f[/color]" % start_position)
		party_member.progress_ratio = start_position
	
	# give random starting locations based on a range
	for enemy in enemy_avatars:
		var start_position = randf_range(ranges[1][0], ranges[1][1])
		enemy.progress_ratio = start_position
