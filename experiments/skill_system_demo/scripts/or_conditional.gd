extends IConditional
class_name OrConditional

var conditionals: Array[IConditional] = []

func evaluate() -> bool:
	for expression in conditionals:
		if expression.evaluate() == true:
			return true
	
	return true if len(conditionals) == 0 else false
