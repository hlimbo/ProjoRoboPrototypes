extends Node
class_name SkillSystemDemoController

# dependencies
@export var skills_registry: SkillsRegistry = SkillsRegistry

@export var player1: LiteActor
@export var player2: LiteActor
@export var player1_view: CharacterBlock
@export var player2_view: CharacterBlock
@export var battle_console: ConsoleDemoLoader
@export var stat_deltas: StatDeltas

# operations needed - button press
# * when a skill is casted, 
#    - it should do p1 modifies stat values to p2 and vice versa
#    - it should notify battle console of skill being casted
#    - it should notify stat attributes that its value changed
#	 - it should notify stat deltas of the calculations it made

#region Hardcoded Skills that should be pre-configured in a separate file....
#func goblin_punch() -> Skill:
	#var skill = Skill.new()
	#skill.name = "Goblin Punch"
	#skill.cost = 12
	#skill.description = "Adds half your Toughness to your base attack damage"
	#
	#var gob_modifier = Modifier.new()
	#gob_modifier.stat_category_type_src = Constants.STAT_TOUGHNESS
	#gob_modifier.stat_category_type_target = Constants.STAT_HP
	#gob_modifier.stat_value = 50
	#gob_modifier.modifier_type = Constants.MODIFIER_PERCENT
	#var gob_modifier2 = Modifier.new()
	#gob_modifier2.stat_category_type_src = Constants.STAT_STRENGTH
	#gob_modifier2.stat_category_type_target = Constants.STAT_HP
	#gob_modifier2.stat_value = 80
	#gob_modifier2.modifier_type = Constants.MODIFIER_PERCENT
	#skill.modifiers["gob-mod1"] = gob_modifier
	#skill.modifiers["gob-mod2"] = gob_modifier2
	#return skill
#
#func thorny_defense() -> Skill:
	#var skill = Skill.new()
	#skill.name = "Thorny Defense"
	#skill.energy_type = "Wood"
	#skill.description = "Performs guard action and deals wood damage back to opposing bot while guarding. Defense is increased and Speed is decreased while in this stance."
	#skill.cost = 4
	#
	#var thorny_effect = StatusEffect.new()
	#thorny_effect.name = "Thorny Defense"
	#thorny_effect.description = "Deals flat damage back to enemies that attack this character"
	#thorny_effect.duration_type = "SECONDS"
	#thorny_effect.duration = 3
	#thorny_effect.effect_type = "positive"
	#thorny_effect.can_affect_self = false
	#
	#var dmg_modifier = Modifier.new()
	#dmg_modifier.modifier_type = Constants.MODIFIER_FLAT
	#dmg_modifier.stat_category_type_src = Constants.STAT_NONE
	#dmg_modifier.stat_category_type_target = Constants.STAT_HP
	#dmg_modifier.stat_value = 30
	#dmg_modifier.is_positive = false
	#thorny_effect.modifiers["hp-flat-dmg"] = dmg_modifier
	#
	## immediate modifiers - is treated as a status effect because the stat changes are temporary
	#var thorny_effect_stat_buffs = StatusEffect.new()
	#thorny_effect_stat_buffs.name = "Thorny Defense Stat Buffs"
	#thorny_effect_stat_buffs.description = "Increases Defense but Decreases Speed temporarily"
	#thorny_effect_stat_buffs.duration_type = "SECONDS"
	#thorny_effect_stat_buffs.duration = 5
	#thorny_effect_stat_buffs.effect_type = "positive"
	#thorny_effect_stat_buffs.can_affect_self = true
	#
	#var def_modifier = Modifier.new()
	#def_modifier.stat_category_type_src = Constants.STAT_NONE
	#def_modifier.stat_category_type_target = Constants.STAT_TOUGHNESS
	#def_modifier.modifier_type = Constants.MODIFIER_FLAT
	#def_modifier.stat_value = 50
	#def_modifier.is_positive = true
	#
	#var spd_modifier = Modifier.new()
	#spd_modifier.stat_category_type_src = Constants.STAT_NONE
	#spd_modifier.stat_category_type_target = Constants.STAT_SPEED
	#spd_modifier.modifier_type = Constants.MODIFIER_FLAT
	#spd_modifier.stat_value = 25
	#spd_modifier.is_positive = false
	#thorny_effect_stat_buffs.modifiers["toughness-mod"] = def_modifier
	#thorny_effect_stat_buffs.modifiers["speed-mod"] = spd_modifier
	#
	#skill.buffs.append(thorny_effect)
	#skill.buffs.append(thorny_effect_stat_buffs)
#
	#return skill
#
#func system_shock() -> Skill:
	#var skill = Skill.new()
	#skill.name = "System Shock"
	#skill.energy_type = "AI"
	#skill.description = "For the next 2 turns, target bot can only attack the bot who used this skill"
	#skill.cost = 12
	#
	#var dmg_mod = Modifier.new(Constants.STAT_NONE, Constants.STAT_HP, Constants.MODIFIER_FLAT, -12)
	#skill.modifiers["dmg"] = dmg_mod
	#
	#var debuff = StatusEffect.new()
	#debuff.name = "System Shock"
	#debuff.duration_type = "TURN"
	#debuff.duration = 2.0
	#debuff.effect_type = "negative"
	#skill.debuffs.append(debuff)
	#
	#return skill
#
#func burn() -> Skill:
	#var skill = Skill.new()
	#skill.name = "Burn"
	#skill.energy_type = "Fire"
	#skill.description = "Applies burn to a single target"
	#skill.cost = 8
	#
	#var dmg_mod = Modifier.new(Constants.STAT_NONE, Constants.STAT_HP, Constants.MODIFIER_FLAT, 6)
	#dmg_mod.is_positive = false
	#skill.modifiers["dmg-mod"] = dmg_mod
	#
	#var debuff = StatusEffect.new()
	#debuff.name = "Burn"
	#debuff.duration_type = "SECONDS"
	#debuff.duration = 20
	#debuff.is_applied_over_time = true
	#debuff.effect_type = "negative"
	#var burn_mod = Modifier.new(Constants.STAT_NONE, Constants.STAT_HP, Constants.MODIFIER_FLAT, 1)
	#burn_mod.is_positive = false
	#debuff.modifiers["burn-mod"] = burn_mod
	#skill.debuffs.append(debuff)
	#
	#return skill
	#
#func heal() -> Skill:
	#var skill = Skill.new()
	#skill.name = "Heal"
	#skill.cost = 6
	#var heal_mod = Modifier.new(Constants.STAT_NONE, Constants.STAT_HP, Constants.MODIFIER_FLAT, 20)
	#skill.modifiers["heal-mod"] = heal_mod
	#
	#return skill 
	#
#func health_regen() -> Skill:
	#var skill = Skill.new()
	#skill.name = "Health Regen"
	#skill.cost = 4
	#var health_regen = StatusEffect.new()
	#health_regen.name = "Health Regen"
	#health_regen.duration_type = "SECONDS"
	#health_regen.duration = 30
	#health_regen.effect_type = "positive"
	#var heal_mod = Modifier.new(Constants.STAT_SPEED, Constants.STAT_HP, Constants.MODIFIER_PERCENT, 2)
	#health_regen.modifiers["heal-mod"] = heal_mod
	#skill.buffs.append(health_regen)
	#return skill
#
#func corkscrew_slash() -> Skill:
	#var skill = Skill.new()
	#skill.name = "Corkscrew Slash"
	#skill.energy_type = "Wind"
	#skill.description = "Applies a whimsical slash"
	#skill.cost = 4
	#
	#var dmg_mod = Modifier.new(Constants.STAT_NONE, Constants.STAT_HP, Constants.MODIFIER_FLAT, 126)
	#skill.modifiers["dmg-mod"] = dmg_mod
	#return skill

#endregion

func load_skills(player: CharacterBlock):
	var data: Array[Resource] = Utility.load_resources_from_folder("res://experiments/skill_system_demo/skill_resources")
	var skills: Array[Skill] = []
	for item in data:
		skills.append(item as Skill)
	
	#var skills: Array[Skill] = [
		#goblin_punch(), # flat damage + 50% of toughness = total damage immediately (immediate change)
		#thorny_defense(), # inc. defense, dec speed temporarily, thornmail status effect - flat damage when attacked (2 status effects)
		#burn(), # flat damage + burn status effect which applies periodically (immediate change + status effect)
		#heal(), # gives hp back to player immediately (immediate change)
		#health_regen(), # gives hp back to player periodically (status effect)
		#corkscrew_slash(), # flat damage immediately (immediate change)
	#]
	
	player.skills_container.load_skills(skills)
	player.skills_container.on_cast_pressed.connect(on_cast_pressed1)


# 1. Construction Phase
func goblin_punch_skill(skill: Skill) -> GoblinPunchBehavior:
	var goblin_punch = GoblinPunchBehavior.new(skill)
	# bind any status effects that this skill will operate on
	return goblin_punch

func thorny_defense_skill(skill: Skill) -> ThornyDefenseBehavior:
	var thorny_def = ThornyDefenseBehavior.new(skill)
	var thorny_def_effect = ThornyDefenseEffect.new()
	var thorny_def_effect2 = ThornyDefenseEffect2.new()
	
	var effects: Array[StatusEffectBehavior] = [thorny_def_effect, thorny_def_effect2]
	thorny_def.bind_status_effects(player1, player1)
	
	return thorny_def

func system_shock_skill(skill: Skill) -> SystemShockBehavior:
	var system_shock = SystemShockBehavior.new(skill)
	var system_shock_effect = SystemShockEffect.new()
	system_shock.bind_status_effects(player1, player2)
	return system_shock

func heal_skill(skill: Skill) -> HealBehavior:
	var heal = HealBehavior.new(skill)
	
	return heal
	
func heal_regen_skill(skill: Skill) -> HealRegenBehavior:
	var heal_regen = HealRegenBehavior.new(skill)
	var heal_regen_effect = HealRegenEffect.new()	
	heal_regen.bind_status_effects(player1, player2)
	
	return heal_regen
	
func burn_skill(skill: Skill) -> BurnBehavior:
	var burn = BurnBehavior.new(skill)
	var burn_effect = BurnEffect.new()
	burn.bind_status_effects(player1, player2)
	
	return burn
	
func corkscrew_slash_skill(skill: Skill) -> CorkscrewSlashBehavior:
	var css = CorkscrewSlashBehavior.new(skill)
	return css

# can be stored in a skill registry of some sort e.g. dictionary 
# whose job is to instantiate new skills during runtime to get processed
var thorny_defense_be: ThornyDefenseBehavior
var goblin_punch_be: GoblinPunchBehavior
var system_shock_be: SystemShockBehavior
var heal_be: HealBehavior
var heal_regen_be: HealRegenBehavior
var burn_be: BurnBehavior
var corkscrew_slash_be: CorkscrewSlashBehavior

# caster, target, skill
func on_cast_pressed1(skill: Skill):
	print("handling skill: ", skill.name)
	
	## Goblin Punch
	#goblin_punch_be = skills_registry.create_skill_behavior(skills_registry.GOBLIN_PUNCH, skill)
	#goblin_punch_be.apply_cost(player1, skill)
	#var raw_deltas: ModifierDelta = goblin_punch_be.accumulate_raw_stat_changes(player1, player2, skill)
	#var net_deltas: ModifierDelta = goblin_punch_be.compute_stat_changes(player2, raw_deltas)
	#goblin_punch_be.apply_stat_changes(player2, net_deltas)
	
	### Thorny Defense
	#thorny_defense_be = skills_registry.create_skill_behavior(skills_registry.THORNY_DEFENSE, skill)
	#thorny_defense_be.bind_status_effects(player1, player1)
	#var raw_deltas: ModifierDelta = thorny_defense_be.accumulate_raw_stat_changes(player1, player1, skill)
	#var net_deltas: ModifierDelta = thorny_defense_be.compute_stat_changes(player1, raw_deltas)
	#thorny_defense_be.apply_stat_changes(player1, net_deltas)
	#thorny_defense_be.start_status_effects(player1, skill)
	
	## System Shock
	#system_shock_be = skills_registry.create_skill_behavior(skills_registry.SYSTEM_SHOCK, skill)
	#system_shock_be.bind_status_effects(player1, player2)
	#var raw_deltas: ModifierDelta = system_shock_be.accumulate_raw_stat_changes(player1, player2, skill)
	#var net_deltas: ModifierDelta = system_shock_be.compute_stat_changes(player2, raw_deltas)
	#system_shock_be.apply_stat_changes(player2, net_deltas)
	#system_shock_be.start_status_effects(player2, skill)
	
	## Heal
	#heal_be = skills_registry.create_skill_behavior(skills_registry.HEAL, skill)
	#var raw_deltas: ModifierDelta = heal_be.accumulate_raw_stat_changes(player1, player2, skill)
	#var net_deltas: ModifierDelta = raw_deltas
	#heal_be.apply_stat_changes(player2, raw_deltas)
	
	## Heal Regen
	#heal_regen_be = skills_registry.create_skill_behavior(skills_registry.HEALTH_REGEN, skill)
	#heal_regen_be.bind_status_effects(player1, player2)
	#var raw_deltas: ModifierDelta = heal_regen_be.accumulate_raw_stat_changes(player1, player2, skill)
	#var net_deltas: ModifierDelta = raw_deltas
	#heal_regen_be.apply_stat_changes(player2, net_deltas)
	#heal_regen_be.start_status_effects(player2, skill)
	
	## Burn
	#burn_be = skills_registry.create_skill_behavior(skills_registry.BURN, skill)
	#burn_be.bind_status_effects(player1, player2)
	#var raw_deltas: ModifierDelta = burn_be.accumulate_raw_stat_changes(player1, player2, skill)
	#var net_deltas: ModifierDelta = burn_be.compute_stat_changes(player2, raw_deltas)
	#burn_be.apply_stat_changes(player2, net_deltas)
	#burn_be.start_status_effects(player2, skill)
	
	## Corkscrew Slash
	corkscrew_slash_be = corkscrew_slash_skill(skill)
	var raw_deltas: ModifierDelta = corkscrew_slash_be.accumulate_raw_stat_changes(player1, player2, skill)
	var net_deltas: ModifierDelta = corkscrew_slash_be.compute_stat_changes(player2, raw_deltas)
	corkscrew_slash_be.apply_stat_changes(player2, net_deltas)
	
	# update stat deltas
	stat_deltas.set_deltas(net_deltas.hp.get_value(), net_deltas.energy.get_value(), net_deltas.strength.get_value(), net_deltas.toughness.get_value(), net_deltas.speed.get_value())

func update_battle_console(player: CharacterBlock):
	pass


func _ready():
	load_skills(player1_view)
	load_skills(player2_view)
	
	player1.stat_attributes.load_stats([999, 400, 100, 100, 100])
	player2.stat_attributes.load_stats([998, 404, 100, 100, 150])
	
	# connect status effects to display on player_view UI example
	player1.status_effects.on_start_buff.connect(player1_view.status_effect_loader.on_add_buff)
	player1.status_effects.on_end_buff.connect(player1_view.status_effect_loader.on_remove_buff)
	player1.status_effects.on_start_debuff.connect(player1_view.status_effect_loader.on_add_debuff)
	player1.status_effects.on_end_debuff.connect(player1_view.status_effect_loader.on_remove_buff)

	player2.status_effects.on_start_buff.connect(player2_view.status_effect_loader.on_add_buff)
	player2.status_effects.on_end_buff.connect(player2_view.status_effect_loader.on_remove_buff)
	player2.status_effects.on_start_debuff.connect(player2_view.status_effect_loader.on_add_debuff)
	player2.status_effects.on_end_debuff.connect(player2_view.status_effect_loader.on_remove_buff)
