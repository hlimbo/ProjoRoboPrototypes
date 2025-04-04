shader_type canvas_item;

uniform float percent : hint_range(0.0, 1.0) = 0.0;
uniform float alpha_val : hint_range(0.0, 1.0) = 0.25;
uniform sampler2D main_texture;

void fragment() {
	vec2 uv_pos = UV.xy;
	vec4 texture_color = texture(main_texture,uv_pos);
	
	float num = smoothstep(0.0, 1.0, 500.0);
	
	vec3 color = num * vec3(uv_pos.x, uv_pos.y, 0.0);
	float alpha = step(percent, uv_pos.x) * smoothstep(0.0, 1.0, alpha_val);
	
	COLOR = texture_color * vec4(color, 1.0);
}