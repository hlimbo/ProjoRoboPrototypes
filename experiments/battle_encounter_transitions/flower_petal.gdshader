shader_type canvas_item;

uniform int petal_count : hint_range(1, 10) = 3;
uniform int petal_multiplier : hint_range(1, 10) = 2;
uniform float circle_radius : hint_range(0.0, 1.0) = 0.1;
uniform float time_scale : hint_range(0.0, 1.0) = 0.25;
uniform vec3 bg_color : source_color = vec3(0.0);
uniform float h : hint_range(0.0, 1.0) = 0.1;
uniform sampler2D main_texture;

// returns the y value that paint should be placed on
float sine_wave(in vec2 uv) {
	float amplitude = h;
	float wave_frequency = float(petal_multiplier) * TAU;
	float vertical_offset = 0.0;
	float y = amplitude * sin(wave_frequency * uv.x) + vertical_offset;
	return y;
}

void fragment() {
	vec2 uv = UV;
	vec3 color;
	
	// offset to UV center 0.5,0.5
	uv -= vec2(0.5);
	
	// convert to polar coordinates first
	vec2 polar = vec2(atan(uv.y, uv.x), length(uv));
	// this converts polar.x or theta to be from range -pi to pi TO 0 to 1
	// dividing by TAU or 2 * PI solves the issue of having a discontinuous loop
	polar.x = float(petal_count) * polar.x / TAU + TIME * time_scale;
	
	// plot sine wave using polar coordinates
	float y = sine_wave(polar);
	
	// y - 0.01 and y + 0.01 is giving the line some area so it is visible on screen
	// provides sharp lines -- can see jagginess
	// outline
	float petal = step(y-0.1, polar.y) * step(polar.y, y);
	// provides smoother lines like anti-aliasing
	// float petal = 1.0 - smoothstep(0., .025, polar.y - y);
	float circle = 1.0 - step(circle_radius, length(uv));
	// float circle = 1.0 - smoothstep(circle_radius-0.01,circle_radius+0.01, length(uv));
	// circle outline
	// circle = step(circle_radius-0.1, length(uv)) * step(length(uv), circle_radius+0.1);
	
	// linear interpolation
	// shade_color = mix(0.0, 0.5, polar.y - y);
	
	float sun = 1.0 - (petal + circle);
	vec4 texture_color = texture(main_texture,UV.xy);
	vec3 my_color = bg_color;
	my_color *= sun;
	COLOR = texture_color * vec4(my_color, 1.0);
}

