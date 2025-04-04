shader_type canvas_item;

#define RED vec3(1.0, 0.0, 0.0)
#define ORANGE vec3(1.0, 0.5, 0.0)
#define YELLOW vec3(1.0, 1.0, 0.0)
#define GREEN vec3(0.0, 1.0, 0.0)
#define BLUE vec3(0.0, 0.0, 1.0)
#define INDIGO vec3(0.294, 0.0, 0.510)
#define VIOLET vec3(0.588, 0.0, 1.0)

/*
	Math Breakdown
	There are 7 colors in the rainbow: ROYGBIV
	- Red
	- Orange
	- Yellow
	- Green
	- Blue
	- Indigo
	- Violet
	
	UV has 2 dimensions
	- U ranges between 0 and 1 (X)
	- V ranges between 0 and 1  (Y)
	
	Problem 1: how to evenly distribute colors on UV space?
	* Answer: do 1 / number of colors in the rainbow
	
	Problem 2: what is one way to set colors of rainbow using if else statements?
	
	Problem 3: how to set colors of rainbow without using if statements (hint: use step functions)
	
*/

vec3 rainbow_shader(vec2 st) {
		// Problem 2 Answer
	// if (st.y > 0.0 && st.y < 0.14) {
    //     new_color = red;
    // } else if (st.y > 0.14 && st.y < 0.28) {
    //     new_color = orange;
    // } else if (st.y > 0.28 && st.y < 0.42) {
    //     new_color = yellow;
    // } else if (st.y > 0.42 && st.y < 0.56) {
    //     new_color = green;
    // } else if (st.y > 0.56 && st.y < 0.7) {
    //     new_color = blue;
    // } else if (st.y > 0.7 && st.y < 0.84) {
    //     new_color = indigo;
    // } else if (st.y > 0.84) {
    //     new_color = violet;
    // }
	
	// Problem 3 Answer
	
	vec3 new_color = vec3(0.0);
    new_color = step(0.84, st.y) * VIOLET;
    new_color += step(0.7, st.y) * step(st.y, 0.84) * INDIGO;
    new_color += step(0.56, st.y) * step(st.y, 0.7) * BLUE;
    new_color += step(0.42, st.y) * step(st.y, 0.56) * GREEN;
    new_color += step(0.28, st.y) * step(st.y, 0.42) * YELLOW;
    new_color += step(0.14, st.y) * step(st.y, 0.28) * ORANGE;
    new_color += step(0.0, st.y) * step(st.y, 0.14) * RED;
	
	return new_color;
	// Answer 3 Explanation
	// to convert the range check (st.y > 0.0 && st.y < 0.14)
	// I know that the step function sets its output to 0 if the 
	// first argument is bigger than the second argument
	// if the second argument is bigger than or equal to the first
	// set its output to 1
	// How to use 2 step functions to check for lower and upper bounds?
	// ANSWER:
	// logical expression: lower_bound < st.y && st.y < upper_bound
	// math expression: step(lower_bound, st.y) * step(st.y, upper_bound)
	// Multiplication acts as an AND logical operator
	
	// How to convert "else if" branching to a math operator?
	// ANSWER: use + operator
	// why? when the previous step function computation is 0, adding 0 to anything equals anything
	// therefore, the colors are separated between the shader rather than blending the 2 colors together
}

vec3 trapezoid(vec2 st) {
	vec3 color = vec3(0.0);
	
	// unit circle 45 degrees
	vec2 diag = vec2(sqrt(2.0) / 2.0, sqrt(2.0) / 2.0);
	vec2 diag2 = vec2(-sqrt(2.0) / 2.0, sqrt(2.0) / 2.0);
	
	float dist_from_diag = dot(st, diag);
	float dist_from_diag2 = dot(st, diag2);
	
	float left = step(1.0, dist_from_diag);
	float right = step(0.0, dist_from_diag2);
	float top = step(0.84, st.y);
	
	color = left * right * top * RED;
	
	return color;
}

vec3 parallelogram(vec2 st) {
	vec3 color;
	vec2 diag = vec2(-sqrt(2.0) / 2.0, sqrt(2.0) / 2.0);
	float dist_from_diag = dot(diag, st);
	// paint l2r
	float left = step(0.0, dist_from_diag);
	// paint r2l
	float right = step(dist_from_diag, 0.5);
	
    color = left * right * step(0.84, st.y) * VIOLET;
	return color;
}

float plot(vec2 uv, float val) { // this is determining a pixel's channel value
	return smoothstep(val-0.01, val, uv.y) - 
		smoothstep(val, val+0.01, uv.y);
		
	// alternatively can use this one by looks more jagged
	// return step(val-0.1, st.y) - step(val+0.1,st.y);
}

void fragment() {

	vec3 new_color = rainbow_shader(UV.xy);
	//vec3 new_color = trapezoid(UV.xy);
	//vec3 new_color = parallelogram(UV.xy);
	//vec3 new_color = rainbow_shader_diagonal(UV.xy);
	
	COLOR = vec4(new_color, 1.0);
}
