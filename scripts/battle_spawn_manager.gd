extends Node
class_name BattleSpawnManager

const Avatar_Type = Constants.Avatar_Type

const avatar_res_path: String = "res://nodes/battle_timeline/avatar.tscn"
const avatar_res: Resource = preload(avatar_res_path)

const party_member_res: Resource = preload("res://nodes/actors/yellow_mob_2.tscn")
const enemy_member_res: Resource = preload("res://nodes/actors/enemy_placeholder.tscn")

@export var party_member_spawn_count: int
@export var enemy_spawn_count: int

# Justification: At most, game will only have at most 4 party members
# and 8 enemies, using a list here is ok as numbers are low
var party_members: Array[Actor] = []
var enemies: Array[Actor] = []

func _enter_tree():
	party_members = create_actors(party_member_res, Avatar_Type.PARTY_MEMBER, party_member_spawn_count)
	enemies = create_actors(enemy_member_res, Avatar_Type.ENEMY, enemy_spawn_count)

# may need to change function signature later if spawning in different kinds of actor nodes
# as these can differ base on their art style... (their overall structure and function stays same)
# but their art may be different...
func create_actors(actor_res: Resource, avatar_type: Avatar_Type, count: int) -> Array[Actor]:
	var actors: Array[Actor] = []
	for i in range(count):
		# we can maybe use this notification for _notification func to set all the values of the actor?
		#  NOTIFICATION_SCENE_INSTANTIATED = 20
		var actor: Actor = actor_res.instantiate()
		actor.avatar_type = avatar_type
		actor.avatar = avatar_res.instantiate()
		actor.avatar.avatar_type = avatar_type
		actors.append(actor)
		
	return actors

# use case for adding actors during runtime is if their are packs of enemies incoming ...
func add_actor(avatar_type: Avatar_Type, actor_res: Resource):
	var actor: Actor = actor_res.instantiate()
	actor.avatar = avatar_res.instantiate()
	actor.avatar_type = avatar_type
	actor.avatar.avatar_type = avatar_type
	
	if avatar_type == Avatar_Type.PARTY_MEMBER:
		party_members.append(actor)
	elif avatar_type == Avatar_Type.ENEMY:
		enemies.append(actor)
	
func remove_actor_by_index(avatar_type: Avatar_Type, index: int) -> bool:
	var find_and_remove = func(arr: Array[Actor],i: int) -> bool:
		if i < 0 or i >= len(arr):
			return false
		
		var j = 0
		while j < len(arr):
			if arr[j] == arr[i]:
				break
			j += 1
			
		if i != j:
			return false
			
		arr.remove_at(i)
		return true
		
	if avatar_type == Avatar_Type.PARTY_MEMBER:
		return find_and_remove.call(party_members, index)
	elif avatar_type == Avatar_Type.ENEMY:
		return find_and_remove.call(enemies, index)
		
	return false
	
func remove_actor(avatar_type: Avatar_Type, actor: Actor) -> bool:
	var find_and_remove = func(arr: Array[Actor]) -> bool:
		var index = arr.find(actor)
		if index == -1:
			return false
		arr.remove_at(index)
		return true
	
	if avatar_type == Avatar_Type.PARTY_MEMBER:
		return find_and_remove.call(party_members)
	elif avatar_type == Avatar_Type.ENEMY:
		return find_and_remove.call(enemies)
	
	return false

func get_actor(avatar_type: Avatar_Type, index: int) -> Actor:
	var find_actor = func(arr: Array[Actor], i: int) -> Actor:
		if i < 0 or i >= len(arr):
			return null
		
		for j in range(len(arr)):
			if arr[j] == arr[i]:
				return arr[j]
		return null
		
	if avatar_type == Avatar_Type.PARTY_MEMBER:
		return find_actor.call(party_members, index)
	elif avatar_type == Avatar_Type.ENEMY:
		return find_actor.call(enemies, index)
		
	return null
	
func get_all_actors() -> Array[Actor]:
	var all_actors: Array[Actor] = []
	all_actors.append_array(party_members)
	all_actors.append_array(enemies)
	return all_actors
	
func get_party_members() -> Array[Actor]:
	return party_members
	
func get_enemies() -> Array[Actor]:
	return enemies

func _convert_to_avatars(arr: Array[Actor]) -> Array[Avatar]:
	var output: Array[Avatar] = []
	for actor in arr:
		output.append(actor.avatar)
	return output

func get_enemy_avatars() -> Array[Avatar]:
	return _convert_to_avatars(enemies)

func get_party_member_avatars() -> Array[Avatar]:
	return _convert_to_avatars(party_members)
