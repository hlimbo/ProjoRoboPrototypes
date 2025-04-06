// adapted from fencerdevlog -> https://godotshaders.com/shader/2d-spiral-effect/
// logarithmic spiral
shader_type canvas_item;

uniform vec3 spiral_color: source_color = vec3(0.0, 0.0, 0.0);
uniform float frequency: hint_range(0.0, 10.0, 0.1) = 0.0;
uniform float fun: hint_range(0.0, 1000.0) = 0.0;

float draw_spiral(vec2 uv, float rotation) {
	// convert uv coordinates to polar coordinates
	float uv_radius = length(uv);
	float uv_phi = atan(uv.y, uv.x) + rotation;
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

void fragment() {
	// make uv coordinates centered on 0.5, 0.5
	vec2 uv = UV - 0.5;
	float spiral_alpha = draw_spiral(uv, 0.0);
	COLOR = vec4(spiral_color, spiral_alpha);
}