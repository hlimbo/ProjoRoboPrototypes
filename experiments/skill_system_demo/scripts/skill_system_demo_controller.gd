extends IObserverResource
class_name SkillSystemDemoController


@export var player1: LiteActor
@export var player2: LiteActor
@export var player1_view: CharacterBlock
@export var player2_view: CharacterBlock
@export var battle_console: ConsoleDemoLoader
@export var stat_deltas: StatDeltas
# used to identify if its player 1 or 2 in notify() function
var player_tag: String = "player1"

# operations needed - button press
# * when a skill is casted, 
#    - it should do p1 modifies stat values to p2 and vice versa
#    - it should notify battle console of skill being casted
#    - it should notify stat attributes that its value changed
#	 - it should notify stat deltas of the calculations it made

#region Hardcoded Skills that should be pre-configured in a separate file....
func goblin_punch() -> Skill:
	var skill = Skill.new()
	skill.name = "Goblin Punch"
	skill.cost = 12
	skill.description = "Adds half your Toughness to your base attack damage"
	
	var gob_modifier = Modifier.new()
	gob_modifier.stat_category_type_src = Constants.STAT_TOUGHNESS
	gob_modifier.stat_category_type_target = Constants.STAT_HP
	gob_modifier.stat_value = 50
	gob_modifier.modifier_type = Constants.MODIFIER_PERCENT
	var gob_modifier2 = Modifier.new()
	gob_modifier2.stat_category_type_src = Constants.STAT_STRENGTH
	gob_modifier2.stat_category_type_target = Constants.STAT_HP
	gob_modifier2.stat_value = 10
	gob_modifier2.modifier_type = Constants.MODIFIER_PERCENT
	skill.modifiers.append(gob_modifier)
	skill.modifiers.append(gob_modifier2)
	return skill

func thorny_defense() -> Skill:
	var skill = Skill.new()
	skill.name = "Thorny Defense"
	skill.energy_type = "Wood"
	skill.description = "Performs guard action and deals wood damage back to opposing bot while guarding. Defense is increased and Speed is decreased while in this stance."
	skill.cost = 4
	
	var thorny_effect = StatusEffect.new()
	thorny_effect.name = "Thorny Defense"
	thorny_effect.description = "Deals flat damage back to enemies that attack this character"
	thorny_effect.duration_type = "SECONDS"
	thorny_effect.duration = 30
	thorny_effect.can_affect_self = false
	
	var dmg_modifier = Modifier.new()
	dmg_modifier.modifier_type = Constants.MODIFIER_FLAT
	dmg_modifier.stat_category_type_src = Constants.STAT_NONE
	dmg_modifier.stat_category_type_target = Constants.STAT_HP
	dmg_modifier.stat_value = 30
	thorny_effect.modifiers.append(dmg_modifier)
	
	# immediate modifiers - is treated as a status effect because the stat changes are temporary
	var thorny_effect_stat_buffs = StatusEffect.new()
	thorny_effect_stat_buffs.name = "Thorny Defense Stat Buffs"
	thorny_effect_stat_buffs.description = "Increases Defense but Decreases Speed temporarily"
	thorny_effect_stat_buffs.duration_type = "SECONDS"
	thorny_effect_stat_buffs.duration = 10
	thorny_effect_stat_buffs.can_affect_self = true
	
	var def_modifier = Modifier.new()
	def_modifier.stat_category_type_src = Constants.STAT_NONE
	def_modifier.stat_category_type_target = Constants.STAT_TOUGHNESS
	def_modifier.modifier_type = Constants.MODIFIER_FLAT
	def_modifier.stat_value = 50
	
	var spd_modifier = Modifier.new()
	spd_modifier.stat_category_type_src = Constants.STAT_NONE
	spd_modifier.stat_category_type_target = Constants.STAT_SPEED
	spd_modifier.modifier_type = Constants.MODIFIER_FLAT
	spd_modifier.stat_value = -25
	thorny_effect_stat_buffs.modifiers.append(def_modifier)
	thorny_effect_stat_buffs.modifiers.append(spd_modifier)
	
	skill.buffs.append(thorny_effect)
	skill.buffs.append(thorny_effect_stat_buffs)

	return skill

func system_shock() -> Skill:
	var skill = Skill.new()
	skill.name = "System Shock"
	skill.energy_type = "AI"
	skill.description = "For the next 2 turns, target bot can only attack the bot who used this skill"
	skill.cost = 12
	
	var dmg_mod = Modifier.new(Constants.STAT_NONE, Constants.STAT_HP, Constants.MODIFIER_FLAT, -12)
	skill.modifiers.append(dmg_mod)
	
	var debuff = StatusEffect.new()
	debuff.name = "System Shock"
	debuff.duration_type = "TURN"
	debuff.duration = 2.0
	skill.debuffs.append(debuff)
	
	return skill

func burn() -> Skill:
	var skill = Skill.new()
	skill.name = "Burn"
	skill.energy_type = "Fire"
	skill.description = "Applies burn to a single target"
	skill.cost = 8
	
	var dmg_mod = Modifier.new(Constants.STAT_NONE, Constants.STAT_HP, Constants.MODIFIER_FLAT, -6)
	skill.modifiers.append(dmg_mod)
	
	var debuff = StatusEffect.new()
	debuff.name = "Burn"
	debuff.duration_type = "SECONDS"
	debuff.duration = 20
	debuff.is_applied_over_time = true
	var burn_mod = Modifier.new(Constants.STAT_NONE, Constants.STAT_HP, Constants.MODIFIER_FLAT, -1)
	debuff.modifiers.append(burn_mod)
	skill.debuffs.append(debuff)
	
	return skill
	
func heal() -> Skill:
	var skill = Skill.new()
	skill.name = "Heal"
	skill.cost = 6
	var heal_mod = Modifier.new(Constants.STAT_NONE, Constants.STAT_HP, Constants.MODIFIER_FLAT, 20)
	skill.modifiers.append(heal_mod)
	
	return skill 
	
func health_regen() -> Skill:
	var skill = Skill.new()
	skill.name = "Health Regen"
	skill.cost = 4
	var health_regen = StatusEffect.new()
	health_regen.name = "Health Regen"
	health_regen.duration_type = "SECONDS"
	health_regen.duration = 30
	var heal_mod = Modifier.new(Constants.STAT_SPEED, Constants.STAT_HP, Constants.MODIFIER_PERCENT, 2)
	health_regen.modifiers.append(heal_mod)
	skill.buffs.append(health_regen)
	return skill

func corkscrew_slash() -> Skill:
	var skill = Skill.new()
	skill.name = "Corkscrew Slash"
	skill.energy_type = "Wind"
	skill.description = "Applies a whimsical slash"
	skill.cost = 4
	
	var dmg_mod = Modifier.new(Constants.STAT_NONE, Constants.STAT_HP, Constants.MODIFIER_FLAT, -36)
	skill.modifiers.append(dmg_mod)
	return skill

#endregion

func load_skills(player: CharacterBlock):
	var skills: Array[Skill] = [
		goblin_punch(), # flat damage + 50% of toughness = total damage immediately (immediate change)
		thorny_defense(), # inc. defense, dec speed temporarily, thornmail status effect - flat damage when attacked (2 status effects)
		burn(), # flat damage + burn status effect which applies periodically (immediate change + status effect)
		heal(), # gives hp back to player immediately (immediate change)
		health_regen(), # gives hp back to player periodically (status effect)
		corkscrew_slash(), # flat damage immediately (immediate change)
	]
	
	player.skills_container.load_skills(skills)
	player.skills_container.on_cast_pressed.connect(on_cast_pressed1)

# caster, target, skill
func on_cast_pressed1(skill: Skill):
	print("handling skill: ", skill.name)
	
	# B. Skill Effects - Immediate changes to stats that are permanent until end of battle or until someone undoes it
	# 1. Calculate raw stat value changes (accumulators)
	# 2. Obtain net stat value by calculating raw stat values against p2 resistances
	# 3. Assign net stat values to p2 stat attributes
	
	# C. Status Effects
	# 1. Add effects as tags when effect starts
	# 1b. Calculate immdediate stat changes (Option 1)
	# 2. Calculate raw stat value changes (accumulators) on update (Option 2)
	# 3. Calculate net stat value by calculating raw stat value against p2 resistances on update
	# 4. Assign net stat values on update --> Repeat 2-4 until effect duration expires
	# 5. Remove effects using tags when effect ends
	
	
	# challenge: many different ways to implement skill cast behaviour....
	# create an interface whose sole job is to serve as a framework of defining skill behaviours?
	
	var behavior = SkillBehavior.new()
	player_tag = "player1" # a bit hacky as I use this to determine which player_view to update in the notify() function...
	behavior.apply_cost(player1, skill)
	player_tag = "player2"
	var deltas: ModifierDelta = behavior.process_stat_changes(player1, player2, skill)
	stat_deltas.set_deltas(deltas.hp.stat_value, deltas.energy.stat_value, deltas.strength.stat_value, deltas.toughness.stat_value, deltas.speed.stat_value)
	behavior.process_status_effects(player1, player2, skill)
	


# IObserverResource function
# gets called when StatAttributesSet gets updated
func notify(subject: SubjectResource):
	var stat_attributes: StatAttributeSet = subject as StatAttributeSet
	
	if player_tag == "player1":
		player1_view.health.set_stat_value(stat_attributes.hp.value)
		player1_view.energy.set_stat_value(stat_attributes.energy.value)
		player1_view.strength.set_stat_value(stat_attributes.strength.value)
		player1_view.toughness.set_stat_value(stat_attributes.toughness.value)
		player1_view.speed.set_stat_value(stat_attributes.speed.value)
	elif player_tag == "player2":
		player2_view.health.set_stat_value(stat_attributes.hp.value)
		player2_view.energy.set_stat_value(stat_attributes.energy.value)
		player2_view.strength.set_stat_value(stat_attributes.strength.value)
		player2_view.toughness.set_stat_value(stat_attributes.toughness.value)
		player2_view.speed.set_stat_value(stat_attributes.speed.value)

func update_battle_console(player: CharacterBlock):
	pass

func calc_health_delta() -> float:
	return 0.0

func calc_energy_delta() -> float:
	return 0.0

func calc_strength_delta() -> float:
	return 0.0

func calc_toughness_delta() -> float:
	return 0.0

func calc_speed_delta() -> float:
	return 0.0


func update_stats(player: CharacterBlock):
	var hp: float = player.health.value + calc_health_delta()
	var energy: float = player.energy.value + calc_energy_delta()
	var strength: float = player.strength.value + calc_strength_delta()
	var toughness: float = player.toughness.value + calc_toughness_delta()
	var speed: float = player.speed.value + calc_speed_delta()

	player.set_stats(hp, energy, strength, toughness, speed)
	
func _ready():
	load_skills(player1_view)
	load_skills(player2_view)
	
	player1.stat_attributes.add_listener(self)
	player_tag = "player1"
	player1.stat_attributes.load_stats([100, 200, 300, 400, 500])
	
	player2.stat_attributes.add_listener(self)
	player_tag = "player2"
	player2.stat_attributes.load_stats([100, 200, 300, 404, 503])
	
	# calculate buff modifier -- flat example
	var apply_str_speed_buffs = func(fx: StatusEffect):
		print("applying buffs")
		player_tag = "player1"
		for md in fx.get_modifiers():
			if md.stat_category_type_target == Constants.STAT_STRENGTH:
				var new_val: float = player1.stat_attributes.strength.value + md.stat_value
				player1.stat_attributes.set_strength(new_val)
			elif md.stat_category_type_target == Constants.STAT_SPEED:
				var new_val: float = player1.stat_attributes.speed.value + md.stat_value
				player1.stat_attributes.set_speed(new_val)
	
	var undo_str_speed_buffs = func(fx: StatusEffect):
		print("undoing buffs")
		player_tag = "player1"
		for md in fx.get_modifiers():
			if md.stat_category_type_target == Constants.STAT_STRENGTH:
				var new_val: float = player1.stat_attributes.strength.value - md.stat_value
				player1.stat_attributes.set_strength(new_val)
			elif md.stat_category_type_target == Constants.STAT_SPEED:
				var new_val: float = player1.stat_attributes.speed.value - md.stat_value
				player1.stat_attributes.set_speed(new_val)
	
	player1.status_effects.on_start_buff.connect(apply_str_speed_buffs)
	player1.status_effects.on_end_buff.connect(undo_str_speed_buffs)

	# zero modifiers
	var buff = StatusEffect.new()
	buff.name = "Thorny Defense"
	buff.duration_type = "SECONDS"
	buff.duration = 4
	buff.can_affect_self = false
	
	# 2 modifiers
	var effect = StatusEffect.new()
	effect.name = "Strength up/Spd Down"
	effect.duration_type = "SECONDS"
	effect.duration = 3
	var mod1 = Modifier.new(Constants.STAT_NONE, Constants.STAT_STRENGTH, Constants.MODIFIER_FLAT, 20)
	var mod2 = Modifier.new(Constants.STAT_NONE, Constants.STAT_SPEED, Constants.MODIFIER_FLAT, -5)
	effect.modifiers.append(mod1)
	effect.modifiers.append(mod2)
	
	# add to keep track of buff lifetime
	player1.status_effects.on_start_buff.connect(player1_view.status_effect_loader.on_add_buff)
	player1.status_effects.on_start_debuff.connect(player1_view.status_effect_loader.on_add_debuff)
	player1.status_effects.on_end_buff.connect(player1_view.status_effect_loader.on_remove_buff)
	player1.status_effects.on_end_debuff.connect(player1_view.status_effect_loader.on_remove_debuff)
	player1.status_effects.add_buff(buff)
	player1.status_effects.add_buff(effect)
