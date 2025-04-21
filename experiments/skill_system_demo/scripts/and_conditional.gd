extends IConditional
class_name AndConditional

var conditionals: Array[IConditional] = []

func evaluate() -> bool:
	for expression in conditionals:
		if expression.evaluate() == false:
			return false
	
	return false if len(conditionals) > 0 else true
