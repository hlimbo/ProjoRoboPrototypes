extends SkillBehavior
class_name BurnBehavior

func process_stat_changes(caster: LiteActor, target: LiteActor, skill: Skill) -> ModifierDelta:
	print("SKILL BEHAVIOR: caster %s is executing %s on target %s" % [caster.name, skill.name, target.name])
	return ModifierDelta.new()
