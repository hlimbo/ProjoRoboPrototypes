extends Resource
class_name Rule

#region Operators
const AND = "AND"
const OR = "OR"
const NOT = "NOT"
const GREATER = ">"
const LESS = "<"
const EQUAL = "=="
const NOT_EQUAL = "!="
const GTE = ">="
const LTE = "<="
#endregion

#region Simple Data Types
const FLOAT = "float"
const INT = "int"
const BOOL = "bool"
const STRING = "String"
#endregion

@export_enum(AND, OR, NOT, GREATER, LESS, EQUAL, NOT_EQUAL, GTE, LTE)
var operator: String = EQUAL

@export_enum(FLOAT, INT, BOOL, STRING)
var data_type: String = BOOL

# At minimum, a rule has an operator and 2 values
# operator is used to evaluate if 2 values compared result in a true or false statement
@export var float_value1: float
@export var float_value2: float

@export var int_value1: int
@export var int_value2: int

@export var bool_value1: bool
@export var bool_value2: bool

@export var string_value1: String
@export var string_value2: String

@export var rules: Array[Rule] = []

const MAX_RECUR_DEPTH: int = 4

static func convert_to_rule_recursive(rule_json: RuleJsonObject, node: Node, curr_depth: int, max_depth: int) -> Rule:
	var rule = Rule.new()
	assert([AND, OR, NOT, GREATER, GTE, LESS, LTE, EQUAL, NOT_EQUAL].has(rule_json.operator))
	rule.operator = rule_json.operator
	
	if curr_depth >= max_depth:
		print_rich("[color=yellow]Warning reached max recursive depth of %d. Truncating deeply nested rules..." % max_depth)
		print_stack()
		return rule
	
	# recursive step
	if [AND, OR, NOT].has(rule_json.operator):
		var rules: Array[Rule] = []
		for rule_entry in rule_json.rules:
			var sub_rule: Rule = convert_to_rule_recursive(rule_entry, node, curr_depth + 1, max_depth)
			rules.append(sub_rule)
			
		rule.rules = rules
		return rule
		
	# base case
	# check if its using a special keyword like a function name... may be expanded later on to support different keywords
	if rule_json.variable_name == "random": # percentage check
		rule.data_type = FLOAT
		rule.float_value1 = randf()
		assert(rule_json.float_value >= 0.0 and rule_json.float_value <= 1.0, "rule float value must be between 0 and 1")
		rule.float_value2 = rule_json.float_value 
	else:
		assert(node != null)
		# TODO: IMPROVEMENT: support dot notation to obtain properties within properties
		# may require more recursion to solve
		# example string format = status_effects.duration OR player.stat_attributes.speed
		# alternatively, I can piggyback from godot's naming convention when
		# locating child nodes via forward slashes e.g. character/hand/sword
		# OR combine dot notation and forward slashes together e.g. character/hand/sword.damage
		# consider using node.get_node(node_path) to find node reference AND node.get(property_name) to obtain property's value
		# obtain property value from node and use it as a comparison
		var val = node.get(rule_json.variable_name)
		assert(val != null, "%s is not a valid property in the node being accessed" % rule_json.variable_name)

		if val is float:
			rule.data_type = FLOAT
			rule.float_value1 = val as float
			rule.float_value2 = rule_json.float_value
		elif val is int:
			rule.data_type = INT
			rule.int_value1 = val as int
			rule.int_value2 = rule_json.int_value
		elif val is bool:
			rule.data_type = BOOL
			rule.bool_value1 = val as bool
			rule.bool_value2 = rule_json.int_value
		elif val is String:
			rule.data_type = STRING
			rule.string_value1 = val as String
			rule.string_value2 = rule_json.string_value
		else:
			assert(false, "%s must be a float, int, bool, or String" % rule_json.variable_name)
	
	return rule

static func convert_to_rule(rule_json: RuleJsonObject, node: Node = null) -> Rule:
	return convert_to_rule_recursive(rule_json, node, 0, MAX_RECUR_DEPTH)
