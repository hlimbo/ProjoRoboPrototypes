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

@export var rules: Array[Rule]
