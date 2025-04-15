extends Node
class_name PerlinNoiseGenerator

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

# n = row and column lengths
# returns an NxN 2D array of Vector2D
func generate_perlin_noise_map(n: int):
	# 8 cardinal directions in clockwise fashion
	var rotation_count: int = 8
	var rotation_index: int = 0
	var output: Array = []
	for r in range(n):
		var row: Array[Vector2] = []
		for c in range(n):
			# use sine and cos waves to determine what direction to apply to the x and y values
			# of the random noise vector
			# the effect: it gives a predictable shaking pattern centered around the point of interest
			var one_hour_in_millis: int = 3600 * 1000
			var x_sign: float = sign(cos(Time.get_ticks_msec() % one_hour_in_millis))
			var y_sign: float = sign(sin(Time.get_ticks_msec() % one_hour_in_millis))
			
			var x: float = x_sign * randf()
			var y: float = y_sign * randf()
			
			var val = Vector2(x, y)
			row.append(val)
			rotation_index = (rotation_index + 1) % rotation_count
			
		output.append(row)
	
	return output

# original perlin noise uses corners of a grid to compute the noise
# whereas this one uses the 4 adjacent cells to create noise 
func perlin_noise_2d(n: int, gradient_map) -> Array[Vector2]:
	var output: Array[Vector2] = []
	for r in range(n):
		for c in range(n):
			# step 1: pick pseudo random gradient
			var gradient: Vector2 = gradient_map[r][c]
			# step 2: compute dot product for 4 neighbors
			var left: Vector2 = gradient_map[r][c-1] if c-1 >= 0 else gradient
			var right: Vector2 = gradient_map[r][c+1] if c+1 < n else gradient
			var top: Vector2 = gradient_map[r-1][c] if r-1 >= 0 else gradient
			var bottom: Vector2 = gradient_map[r+1][c] if r+1 < n else gradient
			
			var left_offset: Vector2 = gradient - left
			var right_offset: Vector2 = gradient - right
			var top_offset: Vector2 = gradient - top
			var bot_offset: Vector2 = gradient - bottom
			
			var left_dot: float = gradient.dot(left_offset)
			var right_dot: float = gradient.dot(right_offset)
			var top_dot: float = gradient.dot(top_offset)
			var bot_dot: float = gradient.dot(bot_offset)
			
			# step 3 compute weighted sum for X and Y axes
			# random weight is used to randomize values
			var weight: float = 0.5 #randf()
			var x: float = lerp(left_dot, right_dot, weight)
			var y: float = lerp(top_dot, bot_dot, weight)
			var v = Vector2(x,y).normalized()
			output.append(v)

	return output

# n controls how big the 2d array is
# the bigger the more "random" values are available to use
func get_noise_2d(n: int) -> Array[Vector2]:
	var gradient_map = generate_perlin_noise_map(n)
	return perlin_noise_2d(n, gradient_map)

func _ready():
	pass
	#var gradient_table: Array[float] = prep_perlin_table()
	#var grid_1d: Array[float] = prep_1d_grid2()
	#var perlin_values: Array[float] = []
	#
	#for i in range(TABLE_SIZE):
		#var value: float = perlin_noise_1d(grid_1d[i], gradient_table[i])
		#perlin_values.append(value)
	
	#print("table: ", gradient_table)
	#print("perlin 1d values: ", perlin_values)
	
	#var n = 16
	#var gradient_map = generate_perlin_noise_map(n)
	#var perlin_map = perlin_noise_2d(n, gradient_map)
	#print("GRADIENT MAP: ")
	#print(gradient_map)
	#print("PERLIN MAP: ")
	#print(perlin_map)
