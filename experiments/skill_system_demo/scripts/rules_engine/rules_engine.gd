extends Node
class_name RuleEngine

#region Operator Functions
func equals(val1, val2) -> bool:
	return val1 == val2

func not_equals(val1, val2) -> bool:
	return val1 != val2
	
func greater(val1, val2) -> bool:
	return val1 > val2

func less(val1, val2) -> bool:
	return val1 < val2
	
func gte(val1, val2) -> bool:
	return val1 >= val2
	
func lte(val1, val2) -> bool:
	return val1 <= val2
	
# AND
func and_check(rule_flags: Array[bool]) -> bool:
	for flag in rule_flags:
		if flag == false:
			return false
			
	return true
	
# OR
func or_check(rule_flags: Array[bool]) -> bool:
	for flag in rule_flags:
		if flag == true:
			return true
			
	return true if len(rule_flags) == 0 else false
	
# NOT
# not AND
func not_check(rule_flags: Array[bool]) -> bool:
	return not and_check(rule_flags)
#endregion

var operator_table: Dictionary[String, Callable] = {
	Rule.EQUAL: self.equals,
	Rule.NOT_EQUAL: self.not_equals,
	Rule.GREATER: self.greater,
	Rule.LESS: self.less,
	Rule.GTE: self.gte,
	Rule.LTE: self.lte,
	#Rule.AND: self.and_check,
	#Rule.OR: self.or_check,
	#Rule.NOT: self.not_check,
}

func evaluate(rule: Rule) -> bool:
	# recursive steps

	if rule.operator == Rule.AND:
		assert(len(rule.rules) > 0)
		var flags: Array[bool] = []
		for sub_rule in rule.rules:
			var flag: bool = evaluate(sub_rule)
			flags.append(flag)
		return and_check(flags)

	elif rule.operator == Rule.OR:
		assert(len(rule.rules) > 0)
		var flags: Array[bool] = []
		for sub_rule in rule.rules:
			var flag: bool = evaluate(sub_rule)
			flags.append(flag)
		return or_check(flags)
		
	elif rule.operator == Rule.NOT:
		assert(len(rule.rules) > 0)
		var flags: Array[bool] = []
		for sub_rule in rule.rules:
			var flag: bool = evaluate(sub_rule)
			flags.append(flag)
		return not_check(flag)
	# base case
	var evaluator: Callable = operator_table[rule.operator]
	
	var v1
	var v2
	match rule.data_type:
		rule.FLOAT:
			v1 = rule.float_value1
			v2 = rule.float_value2
		rule.INT:
			v1 = rule.int_value1
			v2 = rule.int_value2
		rule.STRING:
			v1 = rule.string_value1
			v2 = rule.string_value2
		rule.BOOL:
			v1 = rule.bool_value1
			v2 = rule.bool_value2
	
	return evaluator.call(v1, v2)
