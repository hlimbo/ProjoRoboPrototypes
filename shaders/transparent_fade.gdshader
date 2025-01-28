shader_type canvas_item;

uniform float transparency_value: hint_range(0,1) = 1.0;

// Simple 4x4 Bayer matrix
const mat4 dither_matrix = mat4(
   vec4(1.0 / 16.0,  9.0 / 16.0,  3.0 / 16.0, 11.0 / 16.0),
   vec4(13.0 / 16.0,  5.0 / 16.0, 15.0 / 16.0,  7.0 / 16.0),
   vec4(4.0 / 16.0, 12.0 / 16.0,  2.0 / 16.0, 10.0 / 16.0),
   vec4(16.0 / 16.0,  8.0 / 16.0, 14.0 / 16.0,  6.0 / 16.0)
);

void fragment() {
	// Called for every pixel the material is visible on.
	// COLOR includes the color value from modulate and self modulate blended together
	// https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvas_item_shader.html#color-and-texture
	// texture(TEXTURE, UV); // samples the texture's original color without modulate and self-modulate applied
	vec4 color = COLOR;
	
	float threshold = 0.0;
	vec2 dither_size = vec2(0.0, 0.0);
	
	if (transparency_value < 1.0) {
		threshold = 0.5;
		dither_size = vec2(2.0, 2.0);
	}
	
	// Determine the pixel position in the dither matrix
    int x = int(mod(FRAGCOORD.x, dither_size.x));
    int y = int(mod(FRAGCOORD.y, dither_size.y));
	
	float dither_threshold = dither_matrix[x][y];
    // Apply dithering: compare the brightness to the threshold
	vec3 perceived_brightness = vec3(0.299, 0.587, 0.114);
    float brightness = dot(color.rgb, perceived_brightness);
    if (brightness < threshold + dither_threshold) {
        color.a = 0.0; // Make transparent if below threshold
    }
	
	COLOR = color * vec4(1.0, 1.0, 1.0, transparency_value);
}
