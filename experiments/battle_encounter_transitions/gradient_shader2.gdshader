shader_type canvas_item;

uniform float light_percentage : hint_range(0.0, 1.0) = 0.0;
uniform float alpha_val : hint_range(0.0, 1.0) = 0.25;
uniform float x_offset : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D main_texture;

float bezier_single(float start, float end, float t) {
	return start * (1.0 - t) * (1.0 - t) + end * 2.0 * (1.0 - t) * t;
}

vec3 bezier(vec3 start, vec3 end, float t) {
	return vec3(
		bezier_single(start.r, end.r, t),
		bezier_single(start.g, end.g, t),
		bezier_single(start.b, end.b, t)
	);
}

void fragment() {
	vec2 uv_pos = UV.xy;
	// sample a fragment pixel from a texture --> obtains texture color
	vec4 texture_color = texture(main_texture,uv_pos);
	vec2 right_offset = vec2(x_offset, 0.0);
	vec4 right_texture_color = texture(main_texture, uv_pos + right_offset);
	
	vec3 color = vec3(1.0);
	
	// increase brightness
	texture_color.rgb = texture_color.rgb + texture_color.rgb * vec3(light_percentage);
	
	// ADD
	// vec4 resulting_color = texture_color + right_texture_color;
	
	// Multiply
	//vec4 resulting_color = texture_color * right_texture_color;
	
	// SUBTRACT
	// vec4 resulting_color = texture_color - right_texture_color;
	
	// inclusive OR
	// vec4 resulting_color = (texture_color + right_texture_color) - (texture_color * right_texture_color);
	
	// exclusive OR
	// vec4 resulting_color = (texture_color + right_texture_color) - 2.0 * (texture_color * right_texture_color);
	
	// linear interpolation -- perserves colors well
	 // vec4 resulting_color = mix(texture_color, right_texture_color, uv_pos.x);
	
	// smear pixels across screen --> move the texture's pixel to the right (this requires sampling colors from its neighbor
	
	// smear effect -- reference (https://discussions.unity.com/t/smear-effect-on-texture2d/874107/2)
	// 1. obtain neighboring fragment
	// 2. obtain X texture color samples between current fragment and neighboring fragment
	// 3. calculate average value of ALL sampled pixels including current and neighboring
	// 4. assign it to the resulting color
	const int SAMPLE_COUNT = 31;
	vec4 texture_samples[SAMPLE_COUNT];
	vec2 curr_pos = uv_pos + right_offset;
	for (int i = 0;i < SAMPLE_COUNT; ++i) {
		texture_samples[i] = texture(main_texture, curr_pos);
		curr_pos += right_offset;
	}
	
	vec3 avg_color = vec3(0.0);
	for (int i = 0;i < SAMPLE_COUNT; ++i) {
		avg_color += texture_samples[i].rgb;
	}
	avg_color += texture_color.rgb;
	avg_color /= float(SAMPLE_COUNT);
	
	vec4 resulting_color = vec4(avg_color.rgb, 1.0);
	
	//vec4 resulting_color;
	//vec3 res_color = bezier(texture_color.rgb, right_texture_color.rgb, uv_pos.x);
	//resulting_color = vec4(res_color, 1.0);
	
	// smoothstep -- does not work
	//float curr_x = uv_pos.x;
	//float right_x = uv_pos.x + right_offset.x;
	//float mid_x = (curr_x + right_x) / 2.0;
	//float gradient = smoothstep(curr_x, right_x, mid_x);
	//vec4 resulting_color = gradient * texture_color * right_texture_color;
	
	//// sample 32 times to the right -- does not work
	//vec4 texture_samples[1];
	//vec2 curr_pos = uv_pos + right_offset;
	//for (int i = 0;i < 1; ++i) {
		//texture_samples[i] = texture(main_texture, curr_pos);
		//curr_pos += right_offset;
	//}
	//
	//vec4 resulting_color = texture_color;
	//
	//for (int i = 0;i < 1; ++i) {
		//resulting_color *= texture_samples[i];
	//}
	
	COLOR = resulting_color * vec4(color, alpha_val);
}