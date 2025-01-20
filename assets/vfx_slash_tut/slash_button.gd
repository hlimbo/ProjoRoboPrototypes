extends Button

@onready var slash_vfx_tutorial: SlashVfxTutorial = $"../SlashVfxTutorial"

func _ready() -> void:
	self.pressed.connect(func(): slash_vfx_tutorial.play = true)
