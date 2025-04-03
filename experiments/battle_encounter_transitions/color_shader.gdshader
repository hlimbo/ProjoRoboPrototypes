shader_type canvas_item;

// set colors based on pixel position
// is that why the transform colors are the way they are for alot of game engines??? WOW!
// red is x
// green is y
// blue can either be x or y since UV is only 2D while transforms can be 3d
void fragment() {
	float r = UV.x; // r is mapped to x
	float g = UV.y; // g is mapped to y
	float b = UV.x; // b can be mapped to anything...
	
	COLOR = vec4(r, g, 0.0,1.0);
}
