shader_type canvas_item;

// number of textures to sample for the smear/blur effect
const int sample_count = 64;

uniform float light_percentage : hint_range(0.0, 1.0) = 0.0;
// used to obtain neighboring fragments
uniform float pixel_offset : hint_range(0.0, 0.1) = 0.0;
// amount of fade to apply in the UV coordinate space
uniform float fade_offset : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D main_texture;

float brightness_calculator(vec2 uv_pos) {
	vec2 offset_point = vec2(0.25, 0.0);
	float dist_from_offset_point = dot(uv_pos - offset_point, uv_pos - offset_point);
	// this line I don't understand at all....
	float dark_magic = smoothstep(uv_pos.x, uv_pos.x + 0.5, dist_from_offset_point) - smoothstep(uv_pos.x - 0.5, uv_pos.x, dist_from_offset_point);
	return (1.0 - dark_magic);
}

float black_fade_calculator(vec2 uv_pos, float shifter) {
	return (1.0 - smoothstep(0.0, uv_pos.x, shifter));
}

vec3 compute_average_color(vec2 uv_pos, vec2 offset) {
	// smear effect -- reference (https://discussions.unity.com/t/smear-effect-on-texture2d/874107/2)
	// 1. obtain neighboring fragment
	// 2. obtain X texture color samples between current fragment and neighboring fragment
	// 3. calculate average value of ALL sampled pixels including current and neighboring
	// 4. assign it to the resulting color
	vec4 texture_samples[sample_count];
	vec2 curr_pos = uv_pos;
	vec3 avg_color = vec3(0.0);
	for (int i = 0;i < sample_count; ++i) {
		texture_samples[i] = texture(main_texture, curr_pos);
		avg_color += texture_samples[i].rgb;
		curr_pos -= offset;
	}
	avg_color /= float(sample_count);
	
	return avg_color;
}

void fragment() {
	// apply motion blur/smear effect by sampling neighboring pixels based on x_offset value
	vec3 color = compute_average_color(UV.xy, vec2(pixel_offset, 0.0));
	// apply brightness from top left corner
	float light_magic = brightness_calculator(UV.xy);
	// apply black fade transition
	float black_fade = black_fade_calculator(UV.xy, fade_offset);
	
	// mixing all the results together
	color = black_fade * (color + color * vec3(light_percentage) * light_magic);
	COLOR = vec4(color, 1.0);
}