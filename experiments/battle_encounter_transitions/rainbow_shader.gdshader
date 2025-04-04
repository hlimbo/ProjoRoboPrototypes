shader_type canvas_item;

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

void fragment() {
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
    vec3 red = vec3(1.0, 0.0, 0.0);
    vec3 orange = vec3(1.0, 0.5, 0.0);
    vec3 yellow = vec3(1.0, 1.0, 0.0);
    vec3 green = vec3(0.0, 1.0, 0.0);
    vec3 blue = vec3(0.0, 0.0, 1.0);
    vec3 indigo = vec3(0.294, 0.0, 0.510);
    vec3 violet = vec3(0.588, 0.0, 1.0);
	
	vec3 new_color = vec3(0.0);
	vec2 st = UV.xy;
	
    new_color = step(0.84, st.y) * violet;
    new_color += step(0.7, st.y) * step(st.y, 0.84) * indigo;
    new_color += step(0.56, st.y) * step(st.y, 0.7) * blue;
    new_color += step(0.42, st.y) * step(st.y, 0.56) * green;
    new_color += step(0.28, st.y) * step(st.y, 0.42) * yellow;
    new_color += step(0.14, st.y) * step(st.y, 0.28) * orange;
    new_color += step(0.0, st.y) * step(st.y, 0.14) * red;
	
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
	
	COLOR = vec4(new_color, 1.0);
}
