shader_type canvas_item;

uniform float scaler : hint_range(1.0, 8.0, 1.0) = 1.0;
uniform float percent : hint_range(0.0, 1.0) = 0.0;
uniform float alpha_val : hint_range(0.0, 1.0) = 0.25;
void fragment() {
	// scale up X
	float scaled_x = UV.x * scaler;
	float scaled_y = UV.y * scaler;
	vec2 uv_pos = UV.xy;
	uv_pos = uv_pos * scaler;
	// wrap around -- repeat square pattern for scaler times
	uv_pos = fract(uv_pos);

	vec3 color = vec3(uv_pos.x, uv_pos.y, 0.0);
	float alpha = step(percent, uv_pos.x) * smoothstep(0.0, 1.0, alpha_val);
	// I need to multiply by the incoming color so I don't override the colors of the target image texture!
	COLOR *= vec4(color, alpha);
}
