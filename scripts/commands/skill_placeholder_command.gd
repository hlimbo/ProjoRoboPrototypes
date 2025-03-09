extends ICommand
class_name SkillPlaceholderCommand

var target: Actor
var skill: Skill
# called when damage calculations occur which will be when skill casted connects to target
var on_damage_calculation: Callable

# Add commands your Actor will perform here in game
func execute(actor: Actor):
	print("%s used %s on %s!!" % [actor.avatar.avatar_data.avatar_name, skill.name, target.avatar.avatar_data.avatar_name])
	actor.start_motion_skill(target, skill, on_damage_calculation)
