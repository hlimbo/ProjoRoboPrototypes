extends Node
class_name BattleSpawnManager

@export var bot_inventory_systems: BotInventorySystems = BotInventorySystems

const avatar_res: Resource = preload("res://nodes/battle_timeline/avatar.tscn")
const actor_res: Resource = preload("res://nodes/actors/actor.tscn")

@export var enemy_spawn_count: int
var avatar_datum: Array[AvatarData] = []

# Justification: At most, game will only have at most 4 party members
# and 8 enemies, using a list here is ok as numbers are low
var party_members: Array[Actor] = []
var enemies: Array[Actor] = []

func _enter_tree():
	
	# create party members
	var party_member_avatar_datum: Array[AvatarData] = bot_inventory_systems.get_party_members()
	for i in range(len(party_member_avatar_datum)):
		var actor: Actor = actor_res.instantiate()
		actor.construct(party_member_avatar_datum[i])
		actor.actor_type = Constants.Actor_Type.PARTY_MEMBER
		actor.avatar = avatar_res.instantiate()
		actor.avatar.construct(party_member_avatar_datum[i])
		actor.avatar.avatar_type = Constants.Avatar_Type.PARTY_MEMBER
		party_members.append(actor)

	# create enemies
	for i in range(enemy_spawn_count):
		var actor: Actor = actor_res.instantiate()
		actor.actor_type = Constants.Actor_Type.ENEMY
		actor.avatar = avatar_res.instantiate()
		actor.avatar.avatar_type = Constants.Avatar_Type.ENEMY
		enemies.append(actor)

# use case for adding actors during runtime is if their are packs of enemies incoming ...
func add_actor(actor_type: Constants.Actor_Type, avatar_type: Constants.Avatar_Type, actor_res: Resource):
	var actor: Actor = actor_res.instantiate()
	actor.avatar = avatar_res.instantiate()
	actor.actor_type = actor_type
	actor.avatar.avatar_type = avatar_type
	
	if avatar_type == Constants.Avatar_Type.PARTY_MEMBER:
		party_members.append(actor)
	elif avatar_type == Constants.Avatar_Type.ENEMY:
		enemies.append(actor)
	
func remove_actor_by_index(actor_type: Constants.Actor_Type, index: int) -> bool:
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
		
	if actor_type == Constants.Actor_Type.PARTY_MEMBER:
		return find_and_remove.call(party_members, index)
	elif actor_type == Constants.Actor_Type.ENEMY:
		return find_and_remove.call(enemies, index)
		
	return false
	
func remove_actor(actor_type: Constants.Actor_Type, actor: Actor) -> bool:
	var find_and_remove = func(arr: Array[Actor]) -> bool:
		var index = arr.find(actor)
		if index == -1:
			return false
		arr.remove_at(index)
		return true
	
	if actor_type == Constants.Actor_Type.PARTY_MEMBER:
		return find_and_remove.call(party_members)
	elif actor_type == Constants.Actor_Type.ENEMY:
		return find_and_remove.call(enemies)
	
	return false

func get_actor(actor_type: Constants.Actor_Type, index: int) -> Actor:
	var find_actor = func(arr: Array[Actor], i: int) -> Actor:
		if i < 0 or i >= len(arr):
			return null
		
		for j in range(len(arr)):
			if arr[j] == arr[i]:
				return arr[j]
		return null
		
	if actor_type == Constants.Actor_Type.PARTY_MEMBER:
		return find_actor.call(party_members, index)
	elif actor_type == Constants.Actor_Type.ENEMY:
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
