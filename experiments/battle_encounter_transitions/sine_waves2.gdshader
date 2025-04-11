shader_type canvas_item;

uniform sampler2D main_texture;

float sine_wave(in vec2 st, float lower, float upper) {
    // frequency - this controls how frequent a sine wave appears on the UV coordinates
	// higher numbers the sine wave appears more often
	// TAU = 2 * PI
	float f = TAU * 9.;
	// amplitude - controls how tall the sine wave is on the UV coordinates
    float a = 0.05;
    float translation = st.y + a * sin(f * st.x);
    // lower <= translation <= upper
	return step(lower, translation) * step(translation, upper);
}

// smoother lines
float sine_wave2(in vec2 st, float mid) {
    float f = 40.0;
    float a = 0.1;
    float translation = st.y + a * sin(f * st.x);
    return smoothstep(mid-0.1, mid, translation) - smoothstep(mid, mid+0.1, translation);
}

void fragment() {
	vec2 st = UV;
	// sample texture fragment
	vec4 texture_color = texture(main_texture, st);
	
	vec3 color = vec3(0.0);
	
    vec3 blue1 = vec3(37., 81., 175.) / 255.0;
    vec3 blue2 = vec3(77., 139., 208.) / 255.0;
    vec3 blue3 = vec3(44., 119., 183.) / 255.0;
	
	
    float speed = 0.5 * TIME;
    
    // move wave down
    st.y = st.y - speed;
    // fract is used to ensure st.y wraps between 0 and 1
    st.y = fract(st.y);
    
    // Repeat sine wave by painting it 5 times
    float lower = 1.0 - 0.2;
    float upper = 0.9;
	// shading helps "hide" the horizontal line when the wave pattern repeats itself
    float shading = smoothstep(lower - 0.1, lower, st.y);
    // use this one for smoother lines
    // sine_wave2(st, 0.9)
    color =  blue1 * shading * sine_wave(st, lower, upper);
    
    lower = 1.0 - 0.4;
    upper = 0.7;
    shading = smoothstep(lower - 0.1, lower, st.y);
    color += blue1 * shading * sine_wave(st, lower, upper);
    
    lower = 1.0 - 0.6;
    upper = 0.5;
    shading = smoothstep(lower - 0.1, lower, st.y);
    color += blue1 * shading * sine_wave(st, lower, upper);
    
    lower = 1.0 - 0.8;
    upper = 0.3;
    shading = smoothstep(lower - 0.1, lower, st.y);
    color += blue1 * shading * sine_wave(st, lower, upper);
    
    lower = 1.0 - 1.0;
    upper = 0.1;
    shading = smoothstep(0.0, upper, st.y);
	color += blue1 * shading * sine_wave(st, lower, upper);
    
    // background color
    color += blue3;
	
	float brightness_factor = 0.2;
	vec3 color_mixer = mix(texture_color.rgb, color, 0.8);
	
	COLOR = vec4(texture_color.rgb * brightness_factor + color, 1.0 * texture_color.a);
}
