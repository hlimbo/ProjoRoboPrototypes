// https://en.wikipedia.org/wiki/Archimedean_spiral
shader_type canvas_item;

uniform float min_man : hint_range(0.0, 1.0) = 0.2;

vec2 to_polar(vec2 cartesian) {
	float theta = atan(cartesian.y, cartesian.x);
	float radius = length(cartesian);
	return vec2(theta, radius);
}

vec2 to_cartesian(vec2 polar) {
	float theta = polar.x * TAU;
	float radius = polar.y;
	return radius * vec2(cos(theta), sin(theta));
}

float plot(vec2 st, float pct){
  return  smoothstep( pct-0.02, pct, st.y) -
          smoothstep( pct, pct+0.02, st.y);
}

// fragment shader only tells the program what color a pixel should
// be at a given location!
// programmers don't have control of where to paint the pixel but rather
// what color should be painted
// use math functions to drive the behavior (a bit backwards in thinking)
void fragment() {
	// remap from 0 to 1 -> -1 to 1
	vec2 uv = (UV - 0.5) * vec2(2.0);
	vec3 my_color;
	
	vec2 polar = to_polar(uv);
	// r = a * theta

	// You can't simply plug-in a formula from wikipedia and have it copy-paste work....
	// it needs to fit within constraints of the program you are working under
	// needs to be computed per fragment on UV
	// controls distance b/w loops
	float b = 1.0;
	// this describes distance from origin to a point in polar coordinates
	// i only have access if I can set the current pixel a specific color or not
	float r_spiral = b * polar.x;
	
	float rays = 0.5;
	float thickness = 0.2;
	float angle = polar.x;
	float r = polar.y;
	
	/*
		original snippet
		1. - smoothstep(-.1, .1, 
                  fract((2.*r-(angle+PI)/TAU)*rays + 
				  (clockwise?1.:-1.)* TIME*speed)-thickness);
	*/
	
	// PI = 180 DEGREES
	// TAU = 2 * PI = 360 DEGREES -> dividing by TAU creates a circle | removing it creates a swirl
	// rays tells us how many swirls to draw
	// TIME - is a global function in gshader that gives us the time that wraps around every 3600 seconds
	// TIME is useful for animating a shader
	// fract - gives us the fractional component of the floating point number
	// how is this useful? this is what allows us to repeat a pattern over and over again
	// which a spiral is... a pattern! (without it you cannot make the spiral)
	// thickness - controls how thick the black lines are
	// smoothstep - gives the curve an area of color where -.1 and .1 are lower and upper bounds
	
	 float spiral_1 = smoothstep(-.1, .9, 
                  fract((TAU*r-angle/PI)*rays + TIME)- thickness);
	float spiral_2 = smoothstep(-.5, .5,
		mod(r + TIME, 0.5));
		
	float spiral_3 = smoothstep(-.1, .1,
		sin(TAU * r + TIME)
	);
	
	float spiral_4 = smoothstep(-.1, .1,
		sin(TAU * r + TIME + PI)
	);
	
	// the further away it is from the center, the less channel value it has
	float alp = step(0.01, min_man) * smoothstep(min_man, 1.0, r) * 0.9;
	
	//r *= 3.0;
	//
	//float spiral_1 = fract(r);
	//my_color.b = spiral_1;
	my_color.g = spiral_3;// * alp;
	my_color.b = spiral_4;
	
	COLOR = vec4(my_color, alp);
}