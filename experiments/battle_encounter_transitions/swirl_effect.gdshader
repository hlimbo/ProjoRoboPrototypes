// adapted from fencerdevlog -> https://godotshaders.com/shader/2d-spiral-effect/
// logarithmic spiral
shader_type canvas_item;

uniform vec3 spiral_color: source_color = vec3(0.0, 0.0, 0.0);
uniform float frequency: hint_range(0.0, 10.0, 0.1) = 0.0;
uniform float fun: hint_range(0.0, 1000.0) = 0.0;

float draw_spiral(vec2 uv) {
	// convert uv coordinates to polar coordinates
	float uv_radius = length(uv);
	float uv_phi = atan(uv.y, uv.x);
	// https://en.wikipedia.org/wiki/Logarithmic_spiral
	// r = a * e^(k * phi)
	
	// inverse of e is natural log -- in glsl it is log
	float spiral_phi = (log(uv_radius) * frequency - uv_phi) / TAU;
	// r = a * e^(k * phi)
	// a = controls how bright something is (scaling factor)
	// k = (1 / frequency) --> growth rate
	// phi = TAU * floor(spiral_phi) + uv_phi
	float spiral_radius = fun * exp((TAU * floor(spiral_phi) + uv_phi) / frequency);
	
	// cutoff point to make something fully opaque as the above formula leaves a tiny circle
	// visible on screen
	spiral_radius = step(1000.0, fun) + spiral_radius;
	return spiral_radius;
}

// black spin around center
uniform float edge1 : hint_range(0.0,1.0) = 0.2;
uniform float edge2 : hint_range(0.0, 1.0) = 0.2;
uniform float stuff : hint_range(0.0, 1.0) = 0.2;
float another_spiral(vec2 uv) {	
	// convert uv coordinates to polar coordinates
	float uv_radius = length(uv);
	// this controls the rotation
	float uv_phi = atan(uv.y, uv.x) / PI;
	
	//// scaling in polar coordinates is weird
	//uv_radius *= 3.0;
	//uv_radius = fract(uv_radius);
	
	// this controls the zooming in/out
	float spiral_phi = (log(uv_radius) / PI);
	float offset = TIME;
	float spiral_radius = uv_radius * PI * sin(spiral_phi * uv_phi + stuff);

	// spiral_radius = step(0.0, spiral_radius) + spiral_radius;
	
	return spiral_radius;
}

float simple_spiral(vec2 uv) {
	float radius = length(uv);
	float theta = atan(uv.y, uv.x) / TAU;
	
	float spiral = sin(10.0 * theta + fun);
	return spiral;
}

void fragment() {
	// make uv coordinates centered on 0.5, 0.5
	vec2 uv = UV - 0.5;
	float spiral_alpha = draw_spiral(uv);
	COLOR = vec4(spiral_color, spiral_alpha);
	
	//// simple spiral
	//float spiral_alpha = simple_spiral(uv);
	//COLOR = vec4(vec3(0.0), spiral_alpha);
	
	
	//// swirler
	//float spiral_alpha = another_spiral(uv);
	//// this adds lower and upper thickness for the spiral
	//float r = length(uv);
	//float ff = step(r-edge1, spiral_alpha) * step(spiral_alpha,r+edge2);
	//
	//COLOR = vec4(spiral_color, ff);
}