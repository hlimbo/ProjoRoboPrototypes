shader_type canvas_item;

uniform sampler2D noise_texture;
uniform float dissolve_amount: hint_range(0.0,1.0) = 0.5;
uniform vec4 dissolve_color: source_color = vec4(1.0, 0.0, 0.0, 1.0);

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec4 noise_val = texture(noise_texture, UV);
	
	float amount = 1.0 - dissolve_amount;
	float stepped_value = step(noise_val.g, amount);
	vec4 white = vec4(1.0, 1.0, 1.0, 1.0);
	vec4 col = white;
	if (dissolve_amount > 0.0) {
		// lerp to smooth out the dissolve color as the material dissolves away
		col = mix(color, dissolve_color, dissolve_amount);
	}
	// returns the color back
	COLOR = stepped_value * color * col;
}