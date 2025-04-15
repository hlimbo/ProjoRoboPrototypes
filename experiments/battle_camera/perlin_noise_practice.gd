extends Node

const TABLE_SIZE = 256

# random values - gradient vectors
func prep_perlin_table() -> Array[float]:
	var output: Array[float] = []
	
	for i in range(TABLE_SIZE):
		var gradient: float = 2.0 * randf() - 1.0
		output.append(gradient)
	
	return output
	
func prep_1d_grid() -> Array[float]:
	var output: Array[float] = []
	
	var mid_offset = 0.5
	for i in range(TABLE_SIZE):
		output.append(float(i) + mid_offset)
	
	return output
	
# generate floating point values between -1 to 1 for normalized noise outputs
func prep_1d_grid2() -> Array[float]:
	var output: Array[float] = []
	
	var mid_offset = 0.5
	# math:
	# 1 / TABLE_SIZE => how much each cell in the array takes up
	# multiply by 2 to go from 0 to 1 TO 0 to 2
	var step: float = 2.0 / TABLE_SIZE
	# apply lower bound of -1 to go from [-1,1)
	var lower: float = -1.0
	var curr: float = lower
	for i in range(TABLE_SIZE):
		output.append(curr)
		curr += step
		
	return output

func perlin_noise_1d(point: float, gradient_val: float) -> float:
	# step 1 pick "pseudo-random" gradient vector G
	var gradient: float = gradient_val
	# step 2 compute dot product between point and diff between point and its neighbors
	var left: float = point - 1 if point - 1 >= 0 else 0
	var right: float = point + 1 if point + 1 < TABLE_SIZE else point
	
	var left_offset: float = left - point
	var right_offset: float = right - point
	var left_dot: float = point * left_offset
	var right_dot: float = point * right_offset
	
	# step 3 interpolate between the left and right dot products
	# to introduce more randomness, use rand function to get random weight between 0 and 1
	var weight: float = randf()
	var value: float = lerpf(left_dot, right_dot, weight)
	# var value: float = smoothstep(left_dot, right_dot, weight)
	return value


func _ready():
	var gradient_table: Array[float] = prep_perlin_table()
	var grid_1d: Array[float] = prep_1d_grid2()
	var perlin_values: Array[float] = []
	
	for i in range(TABLE_SIZE):
		var value: float = perlin_noise_1d(grid_1d[i], gradient_table[i])
		perlin_values.append(value)
	
	print("table: ", gradient_table)
	print("perlin 1d values: ", perlin_values)
