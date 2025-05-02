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

# objs - not all variables in the rule_json will be connected with one another.
# e.g. player.hand.weapon.axe.damage and target.health.value are 2 separate
# entities not connected with one another; therefore, the coder must specify which
# objects the designer will need access to and require communication between them when
# building out new skills or status effects
static func convert_to_rule_recursive(rule_json: RuleJsonObject, objs: Array[Object], curr_depth: int, max_depth: int) -> Rule:
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
			var sub_rule: Rule = convert_to_rule_recursive(rule_entry, objs, curr_depth + 1, max_depth)
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
		assert(len(objs) > 0)
		var val = find_property_from_objects(objs, rule_json.variable_name)
		assert(val != null, "%s is not a valid property in the object being accessed" % rule_json.variable_name)
		print_rich("[color=green]value accessed has value %s [/color]" % str(val))

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

static func convert_to_rule(rule_json: RuleJsonObject, objs: Array[Object] = []) -> Rule:
	return convert_to_rule_recursive(rule_json, objs, 0, MAX_RECUR_DEPTH)

# dotted_path example -> player.hand.weapon.axe.damage
static func find_object_property(root_obj: Object, dotted_path: String) -> Variant:
	assert(len(dotted_path) > 0)
	var tokens: PackedStringArray = dotted_path.split(".")
	var property_reference = root_obj
	for i in range(1, len(tokens)):
		property_reference = property_reference.get(tokens[i])
		
		if property_reference == null:
			print_rich("[color=yellow]Unable to find the property from this object using path %s[/color]" % dotted_path)
			print_stack()
			return null
		
	var is_primitive_type: bool = property_reference is float or property_reference is int or property_reference is bool or property_reference is String
	assert(is_primitive_type, "property being referenced must be a float, int, bool, or String")
	
	return property_reference
	
static func find_property_from_objects(objs: Array[Object], dotted_path: String) -> Variant:
	# remove leading and trailing white spaces
	var path: String = dotted_path.lstrip(" \t\r\n").rstrip(" \t\r\n")
	for obj in objs:
		var property = find_object_property(obj, path)
		if property != null:
			return property
			
	assert(false, "Unable to find property path specified: %s" % path)
	return null
