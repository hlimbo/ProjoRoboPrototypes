extends Node
class_name RuleEngine

#region Operator Functions
static func equals(val1, val2) -> bool:
	return val1 == val2

static func not_equals(val1, val2) -> bool:
	return val1 != val2
	
static func greater(val1, val2) -> bool:
	return val1 > val2

static func less(val1, val2) -> bool:
	return val1 < val2
	
static func gte(val1, val2) -> bool:
	return val1 >= val2
	
static func lte(val1, val2) -> bool:
	return val1 <= val2
	
# AND
static func and_check(rule_flags: Array[bool]) -> bool:
	for flag in rule_flags:
		if flag == false:
			return false
			
	return true
	
# OR
static func or_check(rule_flags: Array[bool]) -> bool:
	for flag in rule_flags:
		if flag == true:
			return true
			
	return true if len(rule_flags) == 0 else false
	
# NOT
# not AND
static func not_check(rule_flags: Array[bool]) -> bool:
	return not and_check(rule_flags)
#endregion

static var operator_table: Dictionary[String, Callable] = {
	Rule.EQUAL: equals,
	Rule.NOT_EQUAL: not_equals,
	Rule.GREATER: greater,
	Rule.LESS: less,
	Rule.GTE: gte,
	Rule.LTE: lte,
}

static func evaluate(rule: Rule) -> bool:
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
		return not_check(flags)
	
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
