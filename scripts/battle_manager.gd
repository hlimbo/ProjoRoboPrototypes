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

@export var enemy_texture: Texture2D

var enemy_spawn_count: int
var party_member_spawn_count: int

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

#var party_member_avatars: Array[Avatar] = []
#var enemy_avatars: Array[Avatar] = []

#var party_members: Array[Actor] = []
#var enemies: Array[Actor] = []

@onready var battle_spawn_manager: BattleSpawnManager = $"../BattleSpawnManager"

@onready var battle_scene: Node2D = $"../BattleScene"

@onready var starting_party_member_positions: Array[Vector2] = [
	$"../BattleScene/PartyMember1".position,
	$"../BattleScene/PartyMember2".position,
	$"../BattleScene/PartyMember3".position,
]

@onready var starting_enemy_positions: Array[Vector2] = [
	$"../BattleScene/Enemy1".position,
	$"../BattleScene/Enemy2".position,
	$"../BattleScene/Enemy3".position,
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
	#stats.hp = randi_range(40, 80)
	# temp - make hp high for testing
	stats.hp = 20
	stats.speed = randi_range(10, 20)
	stats.skill_points = 100

	return stats

func get_starting_timeline_positions() -> Array:
	var party_range = starting_timeline_positions[encounter_type][Actor_Type.PARTY_MEMBER]
	var enemy_range = starting_timeline_positions[encounter_type][Actor_Type.ENEMY]
	return [party_range, enemy_range]

func add_to_line(avatar: Avatar, avatar_line: Path2D, stats: BaseStats, avatar_texture: Texture2D, max_battle_speed: int):
	avatar.texture = avatar_texture
	avatar.name = stats.name
	avatar.move_speed = (stats.speed / float(max_battle_speed)) * 0.25
	avatar.initial_stats.set_stats(stats)
	avatar.curr_stats.set_stats(stats)
	avatar_line.add_child(avatar)
	# set owner of this node to be the root node of the scene it is spawned in
	# if not set, godot scene tree won't recognize its existence
	avatar.owner = avatar_line

func _ready() -> void:
	var party_members: Array[Actor] = battle_spawn_manager.get_party_members()
	var enemies: Array[Actor] = battle_spawn_manager.get_enemies()
	enemy_spawn_count = len(enemies)
	party_member_spawn_count = len(party_members)
	
	# initialize battle participants' base stats
	for i in range(0, party_member_spawn_count):
		var stats = generate_random_stats(Actor_Type.PARTY_MEMBER)
		party_member_stats.append(stats)
		max_battle_speed = maxi(max_battle_speed, stats.speed)
	
	for i in range(0, enemy_spawn_count):
		var stats = generate_random_stats(Actor_Type.ENEMY)
		enemy_stats.append(stats)
		max_battle_speed = maxi(max_battle_speed, stats.speed)
	
	print("battle manager ready called")
	# set starting values for avatar and actors and set random location on path2D
	var party_line: Path2D = one_d_graph.get_node("PartyPath2D")
	var enemy_line: Path2D = one_d_graph.get_node("EnemyPath2D")
	
	for i in range(len(party_members)):
		var actor: Actor = party_members[i]
		var avatar: Avatar = actor.avatar
		var stats: BaseStats = party_member_stats[i]
		var texture: Texture2D = party_member_textures[i]
		
		## Avatar Setup
		add_to_line(avatar, party_line, stats, texture, max_battle_speed)
		
		## Actor Setup
		var start_pos: Vector2 = starting_party_member_positions[i]
		actor.position = start_pos
		var info_display: InfoDisplay = actor.get_info_display()
		info_display.avatar = avatar
		
		actor.battle_manager = self
		info_display.battle_manager = self
		
		# triggers _ready() function to be invoked on the child being added
		battle_scene.add_child(actor)
	
	for i in range(len(enemies)):
		var actor: Actor = enemies[i]
		var avatar: Avatar = actor.avatar
		var stats: BaseStats = enemy_stats[i]
		
		## Avatar Setup
		add_to_line(avatar, enemy_line, stats, enemy_texture, max_battle_speed)

		## Actor Setup
		# TODO - add BattleParticipant flee back here maybe?
		# (enemy_mobs[i] as BattleParticipant).avatar = enemy_avatars[i]
		
		var start_pos: Vector2 = starting_enemy_positions[i]
		actor.position = start_pos
		var info_display: InfoDisplay = actor.get_info_display()
		info_display.avatar = avatar
		
		actor.battle_manager = self
		info_display.battle_manager = self
		
		# Improvement - could re-organize the actor class by creating 2 subclasses party_member and enemy_ai
		var target_selection_area: MobSelection = actor.get_target_selection_area()
		target_selection_area.actor = actor
		
		# triggers _ready() function to be invoked on the child being added
		battle_scene.add_child(actor)
	
	var ranges = get_starting_timeline_positions()
	print ("encounter type: %d" % encounter_type)
	
	# give random starting locations based on a range
	for party_member in party_members:
		var start_position = randf_range(ranges[0][0], ranges[0][1])
		print_rich("[color=yellow]progress ratio picked for party avatar is %f[/color]" % start_position)
		party_member.avatar.progress_ratio = start_position
	
	# give random starting locations based on a range
	for enemy in enemies:
		var start_position = randf_range(ranges[1][0], ranges[1][1])
		enemy.avatar.progress_ratio = start_position
