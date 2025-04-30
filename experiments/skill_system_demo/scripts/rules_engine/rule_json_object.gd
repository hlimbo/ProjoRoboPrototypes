extends Resource
class_name RuleJsonObject

#region Operators - TODO: move these out of here and put it Constants file
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

#region Simple Data Types - TODO: move these out of here and put it Constants file
const FLOAT = "float"
const INT = "int"
const BOOL = "bool"
const STRING = "String"
#endregion

var data_type: String = BOOL

@export_enum(AND, OR, NOT, GREATER, LESS, EQUAL, NOT_EQUAL, GTE, LTE)
var operator: String = EQUAL

# name of the variable in code to read from (need to find and obtain value for comparison)
var variable_name: String

@export var float_value: float
@export var int_value: int
@export var bool_value: bool
@export var string_value: String

@export var rules: Array[RuleJsonObject]

# max number of nested sub rules to prevent infinite recursion
static var MAX_PARSE_DEPTH: int = 4

static func parse_from_json_recursive(json_data: Dictionary, curr_depth: int, max_depth: int) -> RuleJsonObject:
	var rule_object = RuleJsonObject.new()
	if curr_depth >= max_depth:
		print_rich("[color=yellow]Warning! Reached max recursion depth of %d. Will return a default RuleJsonObject instance[/color]" % max_depth)
		print_stack()
		return rule_object
	
	assert("operator" in json_data)
	
	rule_object.operator = json_data["operator"]
	# recursive step
	if [Rule.AND, Rule.OR, Rule.NOT].has(json_data["operator"]):
		var rule_objects: Array[RuleJsonObject] = []
		var rules: Array = json_data["rules"]
		for rule in rules:
			var sub_rule_object: RuleJsonObject = parse_from_json_recursive(rule, curr_depth + 1, max_depth)
			rule_objects.append(sub_rule_object)
	
		rule_object.rules.assign(rule_objects)
		return rule_object
		
	# base case
	assert("variable" in json_data)
	assert("value" in json_data)
	
	rule_object.variable_name = json_data["variable"]
	var value = json_data["value"]
	if value is float:
		rule_object.data_type = Rule.FLOAT
		rule_object.float_value = value
	elif value is int:
		rule_object.data_type = Rule.INT
		rule_object.int_value = value
	elif value is bool:
		rule_object.data_type = Rule.BOOL
		rule_object.bool_value = value
	elif value is String:
		rule_object.data_type = Rule.STRING
		rule_object.string_value = value
	
	return rule_object

static func parse_from_json(json_file_path: String) -> RuleJsonObject:
	var file = FileAccess.open(json_file_path, FileAccess.READ)
	if file.get_open_error() != OK:
		print_rich("[color=red]Failed to open file at %s[/color]" % json_file_path)
		assert(false)
	
	var json_string: String = file.get_as_text()
	var json_data: Dictionary = JSON.parse_string(json_string)
	assert(json_data != null)
	
	var rule_json: RuleJsonObject = parse_from_json_recursive(json_data, 0, MAX_PARSE_DEPTH)
	
	return rule_json
