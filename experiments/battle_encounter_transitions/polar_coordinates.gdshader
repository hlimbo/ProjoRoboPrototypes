// following ronja-tutorials.com -- polar coordinates
shader_type canvas_item;

uniform sampler2D main_texture;

vec2 to_polar(vec2 cartesian) {
	float radius = length(cartesian);
	float angle = atan(cartesian.y, cartesian.x);
	// TAU == 2 * PI => 1 revolution of a circle
	return vec2(angle / TAU, radius);
}

vec2 to_cartesian(vec2 polar) {
	float radius = polar.y;
	float theta = polar.x * TAU;
	vec2 cartesian = vec2(cos(theta), sin(theta));
	return cartesian * radius;
}

vec4 rotate_and_zoom_demo(in vec2 my_uv) {
	vec2 uv = my_uv - 0.5; // remap from being relative to 0 to being relative to 0.5
	uv = to_polar(uv);
	
	// manipulate in polar space here
	
	// this one rotates the image in a counter clockwise direction
	// and zooms the image in and out relative to 0.5, 0.5
	uv.x += TIME * 0.1; // theta
	uv.y *= 1.0 + sin(TIME * 3.0) * 0.2; // radius
	
	uv = to_cartesian(uv);
	uv += 0.5; // uv start in corner of rectangle texture
	
	// fract the pixel so that the texture image repeats itself as it zooms in and out
	uv = fract(uv);
	
	return texture(main_texture, uv);
}

// similar to the FF9 battle encounter transitions
vec4 swirl_demo(in vec2 my_uv) {
	vec2 uv = my_uv - 0.5; // remap from being relative to 0 to being relative to 0.5
	uv = to_polar(uv);
	
	// manipulate in polar space here
	
	// swirls the image by remapping each pixel on screen to be located somewhere else
	// based on the sine function
	uv.x += (sin(TIME)) * uv.y * 2.0; // uv.x is theta
	
	// the ones with a smaller radius should have a darker color
	vec3 color = vec3(1.0, 1.0, 1.0);
	color = smoothstep(0.0, 0.75, uv.y) * color;
	
	uv = to_cartesian(uv);
	uv += 0.5; // uv start in corner of rectangle texture
	
	// fract the pixel so that the texture image repeats itself as it zooms in and out
	// uv = fract(uv);
	
	return texture(main_texture, uv) * vec4(color, 1.0);
}

void fragment() {

	// COLOR = rotate_and_zoom_demo(UV);
	COLOR = swirl_demo(UV);
	
	//// remap coordinates to be from (0,1) to (-1,1)
	//vec2 my_uv = UV;
	//my_uv -= vec2(0.5);
	//my_uv *= vec2(2.0);
//
	//vec2 uv = to_polar(my_uv);
	//uv.x = fract(uv.x);
	//// tile image -- application of scaling on a polar coordinate system
	//uv.x *= 3.0;
	//
	//COLOR = texture(main_texture, uv);
	
	// returns a mango color like circle
	// vec3 color = vec3(fract(uv), 0.0);
	// COLOR = vec4(color, 1.0);
	
	// blends the texture with the shader effect
	// vec4 texture_color = texture(main_texture, UV);
	// COLOR = vec4(color, 1.0) * texture_color;
}
