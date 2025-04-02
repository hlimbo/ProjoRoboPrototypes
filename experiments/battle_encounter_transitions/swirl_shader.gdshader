shader_type canvas_item;

// gives a hint to godot editor to use color wheel
// instead of vec4 input parameters
uniform vec4 my_color : source_color = vec4(1.0, 0.0, 1.0, 1.0);
uniform float percentage : hint_range(0.0, 1.42) = 0.0;
uniform vec2 diagonal_direction = vec2(0.0, 0.0);

void linear_gradient_vertical(inout vec4 color, vec2 uv_pos) {
	float alpha_value = step(percentage, uv_pos.y);
	color.a = alpha_value;
}

void linear_gradient_horizontal(inout vec4 color, vec2 uv_pos) {
	float alpha_value = step(percentage, uv_pos.x);
	color.a = alpha_value;
}

// this should work with any line
// note: for diagonal lines, the percentage needs to exceed 1 as the diagonal distance
// from 1 corner to the furthest opposite corner of a rectangle exceeds 1 which
void linear_gradient_diagonal(inout vec4 color, vec2 uv_pos) {
	vec2 diagonal_point = vec2(0.0, 0.0);
	vec2 diag_point_to_uv_pos = uv_pos - diagonal_point;
	
	// gives us the squared distance between diagonal_to_uv vector and diag_direction vector
	float dist_from_diagonal = dot(diag_point_to_uv_pos, diagonal_direction);
	float alpha_value = 1.0 - step(percentage, dist_from_diagonal);
	
	color.a = alpha_value;
}

// WHY this doesn't work as intended...
// this doesn't create a straight line because its grabbing the distance from the UV origin
// for every pixel... this distance is like the radius of a circle which is why
// when the percentage is at 1, the circle doesn't fully expand outwards out of screen
// as the length of the diagonals on a rectangle can exceed 1 which UV coordinates does not support
void diagonal_arc_transition(inout vec4 color, vec2 uv_pos) {
	// setting this to be a min between the distance and 1.0 will cause it to suddenly have all pixels
	// filled with an alpha value > 0
	float dist = length(uv_pos);
	
	// if distance is at or less than the percentage, set its alpha value to 1; otherwise set it to 0
	 float alpha_value = step(dist, percentage);
	
	color.a = alpha_value;
}

void circle_cutout_transition(inout vec4 color, vec2 uv_pos) {
	// offset to be based on center of uv
	float uv_dist = length(uv_pos - vec2(0.5, 0.5));
	float alpha_value = step(percentage, uv_dist);
	color.a = alpha_value;
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 origin = vec2(0.0, 0.0);
	vec2 end = vec2(1.0, 1.0);
	vec4 color = my_color;
	
	linear_gradient_vertical(color, UV.xy);
	// linear_gradient_horizontal(color, UV.xy);
	//linear_gradient_diagonal(color, UV.xy);
	// circle_cutout_transition(color, UV.xy);
	// diagonal_arc_transition(color, UV.xy);
	
	// this sets the color of a pixel on the material
	// theory runs on the GPU in parallel
	// this returns the color for the shader to render
	COLOR = color;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
