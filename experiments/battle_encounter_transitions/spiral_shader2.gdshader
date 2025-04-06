// credits: https://godotshaders.com/shader/2d-spiral-effect/
// https://en.wikipedia.org/wiki/Logarithmic_spiral
// fencerdevlog
shader_type canvas_item;

// Frequency and A must be moved together to get that spiral transition effect
// like scene in cassette beasts or Ape Escape or even FF9...

uniform vec2 resolution = vec2(600.0, 400.0); // in pixels
uniform vec3 spiral_color: source_color = vec3(0.2, 0.6, 0.3);
uniform float frequency: hint_range(0.0, 10.0, 0.1) = 8.0;
uniform float fun: hint_range(0.0, 1000.0) = 0.0;

uniform float rot: hint_range(0.0, 360.0) = 0.0;

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
	float a = fun;
	float spiral_radius = a * exp((TAU * floor(spiral_phi) + uv_phi) / frequency);
	
	// cutoff point to make something fully opaque as the above formula leaves a tiny circle
	// visible on screen
	spiral_radius = step(1000.0, a) + spiral_radius;
	//float spiral_radius = exp(floor(log(uv_radius)) + uv_phi);
	return spiral_radius;
}

void fragment() {
	// make uv coordinates centered on 0.5, 0.5
	vec2 uv = UV - 0.5;
	// maintain aspect ratio of texture
	uv.x *= resolution.x / resolution.y;
	float spiral = draw_spiral(uv, 0.0);
	
	vec3 color = spiral_color;
	COLOR = vec4(color, spiral);
}
