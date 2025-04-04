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

void draw_border2(inout vec4 color, vec2 uv_pos) {
	// start with a black canvas
	color = vec4(0.0, 0.0, 0.0, 1.0);
	
	// translations -- apply color white to the neighboring pixels
	vec2 translate = vec2(0.0, sin(TIME));
	uv_pos += translate;

	// color manipulation
	float left = step(0.1, uv_pos.x);
	float top = step(0.1, uv_pos.y);
	float right = step(0.1, 1.0 - uv_pos.x);
	float bot = step(0.1, 1.0 - uv_pos.y);
	// painting
	// move the absence of color from top to bottom on left edge only
	float redness = 0.25;
	float greenness = 0.0;
	float blueness = 0.25;
	
	float red_channel = redness * left * top * right * bot;
	float green_channel = greenness * left * top * right * bot;
	float blue_channel = blueness * left * top * right * bot;
	
	color = vec4(vec3(red_channel, green_channel, blue_channel), 1.0);
}

uniform float y_mover : hint_range(-1.0, 1.0, 0.1) = 0.1;
uniform float width : hint_range(0.0, 0.5, 0.001) = 0.1;
uniform float height : hint_range(0.0, 0.5, 0.001) = 0.1;
vec4 move_box(vec4 color, vec2 uv_pos) {
	// start with a black canvas
	color = vec4(0.0, 0.0, 0.0, 1.0);
	vec2 center = vec2(0.5);
	
	
	// translations -- apply color white to the neighboring pixels
	// oscillates between -1 and 1 ==> sin(TIME)
	vec2 translate = vec2(0.0, sin(y_mover));
	uv_pos += translate;

	// color manipulation - telling if this pixel can be painted or not
	float left = step(width, uv_pos.x);
	float top = step(height, uv_pos.y);
	float right = step(width, 1.0 - uv_pos.x);
	float bot = step(height, 1.0 - uv_pos.y);
	// painting -- how to leave purple behind where it was? (scale?)
	// move the absence of color from top to bottom on left edge only
	float redness = 0.25;
	float greenness = 0.0;
	float blueness = 0.25;
	
	float red_channel = redness * left * top * right * bot;
	float green_channel = greenness * left * top * right * bot;
	float blue_channel = blueness * left * top * right * bot;
	
	color = vec4(vec3(redness, greenness, blueness), red_channel);
	return color;
}

float movingLine(vec2 uv, vec2 center, float radius) {
	float theta0 = degrees_angle;//90.0;
	vec2 d = uv - center;
	
	vec2 unit_circle_vector = radius * vec2(cos(theta0 * PI/180.0), -sin(theta0*PI/180.0));
	float vector_projection = clamp(dot(d, unit_circle_vector) / dot(unit_circle_vector, unit_circle_vector), 0.0, 1.0);
	float line_length = length(d - vector_projection * unit_circle_vector);
	return smoothstep(0.0, 1.0, line_length);
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

// will claude3 one-shot this? no sadly not....
void circle_swirl2(inout vec4 color, vec2 uv_pos) {
	vec2 center = vec2(0.5, 0.5);
    // Calculate the vector from the center to the current fragment
    vec2 vectorToFragment = uv_pos - center;

    // Calculate the angle of the vector
    float angle = atan(vectorToFragment.y, vectorToFragment.x);

    // Calculate the distance from the center
    float dist = length(vectorToFragment);

    // Calculate the spiral position
	float turns = 3.0;
	float radius = 0.5;
	float thickness = 0.2;
    float spiralPosition = dist / radius - angle / (2.0 * PI * turns);

    // Calculate the alpha value based on the spiral position
    float alpha = 1.0 - smoothstep(spiralPosition - thickness / 2.0, spiralPosition + thickness / 2.0, 1.0);
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

void fragment() {
	// vec4 color = vec4(0.0, 0.0, 0.0, 0.0);
	// color += movingLine(UV.xy, vec2(0.5), 0.1) * vec4(1.0, 0.0, 0.0, 1.0); //move_box(color, UV.xy);
	
	vec4 color = vec4(0.0, 1.0, 0.0, 1.0);
	linear_gradient_diagonal(color, UV.xy);
	
	//color.g = 1.0;
	
	// this sets the color of a pixel on the material
	// theory runs on the GPU in parallel
	// this returns the color for the shader to render
	COLOR = color;
}
