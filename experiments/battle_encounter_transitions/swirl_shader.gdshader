shader_type canvas_item;

// gives a hint to godot editor to use color wheel
// instead of vec4 input parameters
uniform vec4 my_color : source_color = vec4(1.0, 0.0, 1.0, 1.0);
uniform float percentage : hint_range(0.0, 2.0) = 0.0;
uniform vec2 diagonal_direction = vec2(0.0, 0.0);

uniform float degrees_angle : hint_range(0.0, 360.0) = 0.0;

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

// pos is centered at uv 0.5, 0.5
float safe_atan(vec2 pos) {
	// check which side its on (e.g. up or down?)
	float tolerance = 0.0001; // nearly zero
	if (step(tolerance, pos.x) == 0.0) {
		float val = sin(pos.y);
		if (val == 1.0) {
			return PI / 2.0;
		} else {
			return (3.0 / 2.0) * PI;
		}
	}

	// range is between -PI and PI...
	// https://registry.khronos.org/OpenGL-Refpages/gl4/html/atan.xhtml
	return atan(pos.y, pos.x);
}

// controlled by the percentages
void rectangular_swirl(inout vec4 color, vec2 uv_pos) {
	vec2 up = vec2(0.0, -1.0);
	vec2 left = vec2(-1.0, 0.0);
	vec2 down = vec2(0.0, 1.0);
	vec2 right = vec2(1.0, 0.0);
	
	vec2 center = vec2(0.5, 0.5);
	vec2 center_to_point = uv_pos - center;
	
	// may need to take arctan of center to point
	// to see what quadrant it is on?
	// 1st quadrant - sin and cos are positive
	// 2nd quadrant - sin is positive
	// 3rd quadrant - tan is positive
	// 4th quadrant - cos is positive
	
	float angle = safe_atan(center_to_point);
	
	// angle method
	// I want a pixel to show up if its angle goes past a certain threshold
	
	// vector method -- is this the dot product again?
	// a = up
	// b = right
	// length(a) * length(b) * cos theta
	// theta = arc cos ( length(a) * length(b) / a dot b)
	// angle between a and b
	
	// P = pixel vector relative to 0.5, 0.5
	// take dot product between P and a to find angle between P and a
	// if angle between P and a > angle between a and b --> outside range don't render
	// if angle between P and a <= angle between a and b --> inside range render
	
	// if a pixel is between 2 vectors, render it, otherwise don't render it
	
	// doesn't work... doesn't create the cone shape I was looking for
	// angle between up and right relative to up
	//float d1 = acos(dot(up, right) / (length(up) * length(right)));
	//float d2 = acos(dot(up, center_to_point) / length(up) * length(center_to_point));
	//
	//// within angle
	//float alpha_value = 0.0;
	//if (d2 <= d1) {
		//alpha_value = 1.0;
	//}
	
	// RELATIVE to 0.5, 0.5
	// determinant tells us the area of the parallelogram formed by the 2 vectors
	// it also tells us if it has a positive or negative area 
	// this is used to tell us the orietnation of the vector
	// negative sign flips the orientation
	
	// top right
	//float det = determinant(mat2(up, right));
	//float cross_sign = sign(det);
	//// compute dot product of 2 original vectors against center_to_point vector
	//float d1 = dot(center_to_point, up);
	//float d2 = dot(center_to_point, right);
	
	// top left
	//float det = determinant(mat2(up, left));
	//float cross_sign = sign(det);
	//float d1 = -dot(center_to_point, up);
	//float d2 = -dot(center_to_point, left);
	
	// bottom left -- hard to get...
	//float det = determinant(mat2(down, left));
	//float cross_sign = sign(det);
	//float d1 = -dot(center_to_point, down);
	//float d2 = -dot(center_to_point, left);
	
	// bottom right -- hard to get...
	//float det = determinant(mat2(down, right));
	//float cross_sign = sign(det);
	//float d1 = dot(center_to_point, down);
	//float d2 = dot(center_to_point, right);

	float deg_radians = degrees_angle * (PI / 180.0);
	vec2 angle_vector = vec2(cos(deg_radians), sin(deg_radians));

	float det = determinant(mat2(up, angle_vector));
	float cross_sign = sign(det);
	float d1 = dot(center_to_point, up);
	float d2 = dot(center_to_point, angle_vector);
	
	
	bool is_between = sign(d1) == cross_sign && sign(d2) == cross_sign;
	
	float alpha_value = 0.0;
	if (is_between) {
		float dist = dot(center_to_point, angle_vector);
		float dist2 = length(center_to_point - angle_vector);
		alpha_value = step(percentage, dist);
	}
	
	color.a = alpha_value;
}

// spins around a rectangle that is facing right
void circle_swirl(inout vec4 color, vec2 uv_pos) {
	vec2 center = vec2(0.5, 0.5);
	float degrees_radian = degrees_angle * (PI / 180.0);
	// unit circle
	vec2 angle_vector = vec2(cos(degrees_radian), sin(degrees_radian));
	
	vec2 center_to_point = uv_pos - center;
	
	color.a = sign(dot(center_to_point, angle_vector));
}

// this can be used as a transition to hide/reveal a new scene
// https://thebookofshaders.com/07/
void draw_border(inout vec4 color, vec2 uv_pos) {
	//defines which side will be painted black
	float left = step(0.1, uv_pos.x);
	float bottom = step(0.1, uv_pos.y);
	
	float right = step(0.1, 1.0 - uv_pos.x);
	float top = step(0.1, 1.0 - uv_pos.y);
	
	vec3 right_top = vec3(right * top);
	vec3 left_bottom = vec3(left * bottom);

	// Multiplication acts as a logical AND
	color = vec4(vec3(right_top.x * right_top.y * left_bottom.x * left_bottom.y), 1.0);


	// longer way using if else statements equivalent to above
	// drawing a border based on the pixel positions
	//if (uv_pos.x < 0.1) {
		//color = vec4(vec3(0.0), 1.0);
	//} else if (uv_pos.x > 0.9) {
		//color = vec4(vec3(0.0), 1.0);
	//} else if (uv_pos.y < 0.1) {
		//color = vec4(vec3(0.0), 1.0);
	//} else if (uv_pos.y > 0.9) {
		//color = vec4(vec3(0.0), 1.0);
	//}
	
	// this gradually paints the material from black to blue based on pixel coordinates
	// float x_width = smoothstep(0.1, 0.9, uv_pos.x);
	// float y_height = smoothstep(0.1, 0.9, uv_pos.y);
	
	// color = vec4(vec3(0.0, 0.0, x_width * y_height), 1.0);
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

void circle(inout vec4 color, vec2 uv_pos) {
	vec2 center = vec2(0.5, 0.5);
	float uv_dist = length(uv_pos - center);
	float radius = 0.1;
	float alpha_value = step(radius, uv_dist);
	color.a = alpha_value;
}

uniform float line_thickness = 20.0;
void rotating_line(inout vec4 color, vec2 uv_pos) {
	float degrees_radian = TIME;
	// unit circle
	vec2 angle_vector = vec2(cos(degrees_radian), sin(degrees_radian));
	vec2 center = vec2(0.5, 0.5);	

	vec2 center_to_point = uv_pos - center;
	
	// sin range is between -1 to 1 remap it to be between 0 and 1
	float line_thick = line_thickness * (2.0 - sin(TIME));
	// if dot product is 0 or form a perpendicular line, then the value it will paint onto the UV location
	// is 0, otherwise, it will paint 1 for alpha value via step function
	float line = length(line_thick * angle_vector * dot(center_to_point, angle_vector));
	
	color.a = step(0.1,line);
}

void polar_circle(inout vec4 color, vec2 uv_pos) {
	vec2 center = vec2(0.5, 0.5);
	vec2 center_to_point = center - uv_pos;
	
	float r = length(center_to_point)*1.0;
	float a = atan(center_to_point.y, center_to_point.x);
	
	float f = cos(a);
	float smoothstepper = smoothstep(f, f+0.2, r);
	color = vec4(color.rgb, smoothstepper);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 origin = vec2(0.0, 0.0);
	vec2 end = vec2(1.0, 1.0);
	vec4 color = my_color;
	
	//linear_gradient_vertical(color, UV.xy);
	// linear_gradient_horizontal(color, UV.xy);
	//linear_gradient_diagonal(color, UV.xy);
	// circle_cutout_transition(color, UV.xy);
	// diagonal_arc_transition(color, UV.xy);
	// circle_swirl(color, UV.xy);
	//rectangular_swirl(color, UV.xy);
	// draw_border(color, UV.xy);
	// circle(color, UV.xy);
	// polar_circle(color, UV.xy);
	rotating_line(color, UV.xy);
	
	// this sets the color of a pixel on the material
	// theory runs on the GPU in parallel
	// this returns the color for the shader to render
	COLOR = color;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
