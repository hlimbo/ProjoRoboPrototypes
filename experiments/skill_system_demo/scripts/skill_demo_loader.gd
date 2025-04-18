extends BoxContainer
class_name SkillDemoLoader

# node reference to the skill_demo_view
@export var skill_demo_view: Resource
@export var skills: Array[Skill] = []

signal on_cast_pressed(skill: Skill)

func load_skills(_skills: Array[Skill]):
	skills = _skills
	for skill in skills:
		var view = skill_demo_view.instantiate() as SkillDemoView
		self.add_child(view)
		view.set_fields(skill.name, skill.cost)
		view.on_cast_pressed.connect(func(): _on_cast_pressed(skill))
		
func _on_cast_pressed(skill: Skill):
	on_cast_pressed.emit(skill)
