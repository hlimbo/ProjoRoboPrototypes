extends StatusEffectBehavior
class_name BurnEffect

func process_stat_changes():
	print("processing status effect: ", self.status_effect.name)
	print("process duration type: ", self.status_effect.duration_type)
