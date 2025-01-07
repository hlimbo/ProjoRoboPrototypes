extends Node

const avatar_res_path: String = "res://nodes/battle_timeline/avatar.tscn"
const avatar_res: Resource = preload(avatar_res_path)

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

var battle_participants: Array[Node] = []

func generate_random_stats(actor_type: Actor_Type) -> BaseStats:
	var stats = BaseStats.new()
	
	if actor_type == Actor_Type.PARTY_MEMBER:
		stats.name = party_member_names[randi_range(0, len(party_member_names) - 1)]
	else:
		stats.name = enemy_names[randi_range(0, len(enemy_names) - 1)]
	
	stats.attack = randi_range(10, 20)
	stats.defense = randi_range(10, 20)
	stats.hp = randi_range(40, 80)
	stats.speed = randi_range(10, 20)
	stats.skill_points = 100

	return stats

func get_starting_timeline_positions() -> Array:
	var party_range = starting_timeline_positions[encounter_type][Actor_Type.PARTY_MEMBER]
	var enemy_range = starting_timeline_positions[encounter_type][Actor_Type.ENEMY]
	return [party_range, enemy_range]

func _init() -> void:
	print("init called")

func _enter_tree() -> void:
	print("enter tree called")
	
	# initialize party member and enemy base stats
	var max_battle_speed: int = 0
	for i in range(0, party_member_spawn_count):
		var stats = generate_random_stats(Actor_Type.PARTY_MEMBER)
		party_member_stats.append(stats)
		max_battle_speed = maxi(max_battle_speed, stats.speed)
	
	for i in range(0, enemy_spawn_count):
		var stats = generate_random_stats(Actor_Type.ENEMY)
		enemy_stats.append(stats)
		max_battle_speed = maxi(max_battle_speed, stats.speed)
	
	
	
	# load avatars and set random location on path2D
	var one_d_graph: Control = $UILayout/OneDGraph
	var party_line: Path2D = one_d_graph.get_node("PartyPath2D")
	var enemy_line: Path2D = one_d_graph.get_node("EnemyPath2D")
	for i in range(0, party_member_spawn_count):
		var avatar: Avatar = avatar_res.instantiate()
		avatar.texture = party_member_textures[i]
		avatar.move_speed = (party_member_stats[i].speed / float(max_battle_speed)) * 0.25
		avatar.initial_stats.set_stats(party_member_stats[i])
		avatar.curr_stats.set_stats(party_member_stats[i])
		avatar.avatar_type = Avatar.Avatar_Type.PARTY_MEMBER
		
		party_line.add_child(avatar)
		party_member_avatars.append(avatar)
		avatar.name = party_member_stats[i].name

	for i in range(0, enemy_spawn_count):
		var avatar: Avatar = avatar_res.instantiate()
		avatar.texture = enemy_texture
		avatar.move_speed = (enemy_stats[i].speed / float(max_battle_speed)) * 0.25
		enemy_line.add_child(avatar)
		enemy_avatars.append(avatar)
		avatar.name = enemy_stats[i].name
		avatar.initial_stats.set_stats(enemy_stats[i])
		avatar.curr_stats.set_stats(enemy_stats[i])
		avatar.avatar_type = Avatar.Avatar_Type.ENEMY
		

	# spawn party members and enemies
	var starting_positions = [
		$PartyMember1.position,
		#$PartyMember2.position,
		#$PartyMember3.position,
		$Enemy1.position,
		#$Enemy2.position,
		#$Enemy3.position,
	]
	
	var mobs = [
		preload("res://nodes/temp/yellow_mob.tscn"),
		#preload("res://nodes/temp/freddy.tscn"),
		#preload("res://nodes/temp/green_pill.tscn"),
		preload("res://nodes/temp/blue_mob.tscn"),
		#preload("res://nodes/temp/green_mob.tscn"),
		#preload("res://nodes/temp/red_mob.tscn"),
	]
	
	for i in range(0, len(starting_positions)):
		var mob = mobs[i]
		var start_pos = starting_positions[i]
		
		var m = mob.instantiate()
		add_child(m)
		m.position = start_pos
		battle_participants.append(m)
	
	var enemy_mobs: Array[Node] = battle_participants.filter(
			func(b: Node): return (b as BattleParticipant) != null)

	# TODO - looks super hacky... need to possibly consolidate the script into 1 later on...
	# set avatar references from other scripts here
	for i in range(0, len(enemy_mobs)):
		(enemy_mobs[i] as BattleParticipant).avatar = enemy_avatars[i]
		(enemy_mobs[i].get_node("Area2D") as MobSelection).avatar = enemy_avatars[i]
		(enemy_mobs[i].get_node("InfoNode") as InfoDisplay).avatar = enemy_avatars[i]
	
	var party_members: Array[Node] = battle_participants.filter(
		func(b: Node): return (b as BattleParticipant) == null
	)
	
	# set names - party members
	for i in range(0, len(party_member_stats)):
		battle_participants[i].name = party_member_stats[i].name
		
	for i in range(len(party_members)):
		(party_members[i].get_node("InfoNode") as InfoDisplay).avatar = party_member_avatars[i]

func _ready() -> void:
	print("battle scene ready called")
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
