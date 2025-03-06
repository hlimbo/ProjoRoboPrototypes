# This class represents all vfx, particle effects, and text ui required
# to display a visual effect on a screen. Use cases include casting a skill to deal damage or heal a target
extends BaseResource
class_name SkillCue

# These can include things like Vfx, Particle Effects, TextUI and Audio 
# I may need to revisit this if more granular control is needed
# The assumption here is that I can just call the play() function to have all these visual and audio effects play together
@export var resources: Array[Resource]

# Since GPUParticle2D, Texture2D, Audio, and TextLabel have different ways of displaying programmatically
# Throwing it in one function to do it all may require some additional effort to abstract away those details in an interface
# This is an effort to group all visual and audio data to play from one source rather than calling its functions from separate API calls
func play():
	pass
