# Follows ideas from: https://refactoring.guru/design-patterns/factory-method
extends Node
# class_name SkillsRegistry

#region Skill Names
const GOBLIN_PUNCH = "goblin punch"
const THORNY_DEFENSE = "thorny defense"
const SYSTEM_SHOCK = "system shock"
const HEAL = "heal"
const HEALTH_REGEN = "health regen"
const BURN = "burn"
const CORKSCREW_SLASH = "corkscrew slash"
#endregion

#region Skill Behavior Creators
func _goblin_punch(skill: Skill) -> SkillBehavior:
	var goblin_punch = GoblinPunchBehavior.new(skill)
	return goblin_punch

func _thorny_defense(skill: Skill) -> SkillBehavior:
	var buffs: Array[StatusEffectBehavior] = [
		ThornyDefenseEffect.new(), 
		ThornyDefenseEffect2.new()
	]
	var thorny_def = ThornyDefenseBehavior.new(skill, buffs)
	
	return thorny_def

func _system_shock(skill: Skill) -> SkillBehavior:
	var debuffs: Array[StatusEffectBehavior] = [SystemShockEffect.new()]
	var system_shock = SystemShockBehavior.new(skill, [], debuffs)
	return system_shock
	
func _heal(skill: Skill) -> SkillBehavior:
	var heal = HealBehavior.new(skill)
	return heal
	
func _health_regen(skill: Skill) -> SkillBehavior:
	var buffs: Array[StatusEffectBehavior] = [HealRegenEffect.new()]
	var health_regen = HealRegenBehavior.new(skill, buffs)
	return health_regen
	
func _burn(skill: Skill) -> SkillBehavior:
	var debuffs: Array[StatusEffectBehavior] = [BurnEffect.new()]
	var burn = BurnBehavior.new(skill, [], debuffs)
	return burn
	
func _corkscrew_slash(skill: Skill) -> SkillBehavior:
	var corkscrew_slash = CorkscrewSlashBehavior.new(skill)
	return corkscrew_slash
#endregion

# Key - behavior name string
# Value - function that returns a new SkillBehavior reference
var behaviors_factory: Dictionary[String, Callable] = {
	GOBLIN_PUNCH: _goblin_punch,
	THORNY_DEFENSE: _thorny_defense,
	SYSTEM_SHOCK: _system_shock,
	HEAL: _heal,
	HEALTH_REGEN: _health_regen,
	BURN: _burn,
	CORKSCREW_SLASH: _corkscrew_slash,
}

func create_skill_behavior(name: String, skill: Skill) -> SkillBehavior:
	assert(name in behaviors_factory)
	var creator_function: Callable = behaviors_factory[name]
	assert(creator_function.get_argument_count() == 1)
	return creator_function.call(skill)
