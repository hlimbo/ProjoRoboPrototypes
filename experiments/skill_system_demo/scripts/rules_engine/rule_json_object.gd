extends Resource
class_name RuleJsonObject

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
