shader_type canvas_item;

float sine_wave(in vec2 st, float lower, float upper) {
    float f = 40.0; // sine wave frequency - shrinks sine wave the bigger the number along U axis
    float a = 0.1; // sine wave amplitude - shrinks sine wave along V axis the smaller the number
    // Math Breakdown
	// inputing the fragment's location here determines if the given fragment should have color or not
	// >> step(lower, value) * step(value, upper) is equivalent to lower <= st.x <= upper
	// >> addition in the step function is made to determine the y-offset of where to paint
	// >> offset by sine wave to form a sin wave visual in the shader
	// >> a and f are used to ensure the sine wave fits within the UVs boundaries
	return step(lower, st.y + a * sin(f * st.x)) * step(st.y + a * sin(f * st.x), upper);
}


void fragment() {
	vec2 st = UV;
    float speed = TIME;
	vec3 color = vec3(0.0);
    
	float lower = fract(1.0 - 0.2 - speed);
	float upper = fract(0.9 - speed);
	color.r = sine_wave(st, lower, upper);
    
    lower = fract(1.0 - 0.4 - speed);
    upper = fract(0.7 - speed);
    color.r += sine_wave(st, lower, upper);
    
    lower = fract(1.0 - 0.6 - speed);
    upper = fract(0.5 - speed);
    color.r += sine_wave(st, lower, upper);
    
    lower = fract(1.0 - 0.8 - speed);
    upper = fract(0.3 - speed);
    color.r += sine_wave(st, lower, upper);
    
    lower = fract(1.0 - 1.0 - speed);
    upper = fract(0.1 - speed);
    color.r += sine_wave(st, lower, upper);
    
	// vertical green line that moves across the screen
    color.g = step(0.0 + fract(TIME), st.x) * step(st.x, 0.1 + fract(TIME));
	
	COLOR = vec4(color, 1.0);
}

