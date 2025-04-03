shader_type canvas_item;

// how to leave a trail of alphas?
uniform float radius = 0.1;
uniform float rotate_radius : hint_range(0.0, 1.0) = 0.5;
uniform float rotation_speed : hint_range(0.0, 4.0) = 2.0;
void moving_circle(inout vec4 color, vec2 uv_pos) {
	vec2 center = vec2(0.5, 0.5);
	
	// translations first
	vec2 translate = vec2(cos(TIME * rotation_speed), sin(TIME * rotation_speed)) * rotate_radius;
	uv_pos += translate;
	vec2 center_to_point = uv_pos - center;
	
	// can we fill a value on this pixel?
	float dist = length(center_to_point);
	float has_pixel = step(radius, dist);
	
	color.a = has_pixel;
}


void fragment() {
	vec4 color = vec4(0.0, 0.0, 0.0, 1.0);
	moving_circle(color, UV.xy);
	
	COLOR = color;
}
