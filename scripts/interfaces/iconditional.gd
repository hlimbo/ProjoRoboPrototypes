# Why have this class?
# to create a flexible Skill System as not all skills are defined
# by the game designer and follows separation of concerns principle
# Benefit of this class
# allows one to compose conditional logic such as Crit Hit Chance
# and more complex logic that can be created by inheriting this class
extends RefCounted
class_name IConditional

# override this function to add logic that is used to
# determine if something should or should not happen
func evaluate() -> bool:
	return false
