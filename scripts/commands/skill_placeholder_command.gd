extends ICommand
class_name SkillPlaceholderCommand

var target: Actor
var skill: Skill

# Add commands your Actor will perform here in game
func execute(actor: Actor):
	print("%s used %s on %s!!" % [actor.avatar.curr_stats.name, skill.name, target.avatar.curr_stats.name])
