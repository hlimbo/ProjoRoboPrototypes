shader_type canvas_item;

// taken and adapted from easings.net
// these are alternative functions to step(e0, e1) and smoothstep(lower,upper, current)
// math functions
float ease_in_sine(float x) {
    return 1.0 - cos((x * PI) / 2.0);
}

float ease_out_sine(float x) {
   return sin((x * PI) / 2.0);
}

float ease_in_out_sine(float x) {
    return -1.0 * (cos(PI * x) - 1.0) / 2.0;
}

float ease_in_cubic(float x) {
    return x * x * x;
}

float ease_out_cubic(float x) {
    return 1.0 - pow(1.0 - x, 3);
}

float ease_in_out_cubic(float x) {
	// step acts as if statement -- on/of switch
	// multiplication acts as a "then" if the step is true
	// plus sign acts as an else if statement
    return step(x, 0.5) * (4.0 * x * x * x) 
	+ step(0.5, x) * (1.0 - pow(-2.0 * x + 2.0, 3.0) / 2.0);
}

float ease_in_quint(float x) {
    return x * x * x * x * x;
}

float ease_out_quint(float x) {
    return 1.0 - pow(1.0 - x, 5.0);
}

float ease_in_out_quint(float x) {
    return step(x, 0.5) * (16.0 * x * x * x * x * x) 
	+ step(0.5, x) * (1.0 - pow(-2.0 * x + 2.0, 5.0) / 2.0);
}

float ease_in_circ(float x) {
    return 1.0 - sqrt(1.0 - x * x);
}

float ease_out_circ(float x) {
	float k = (x - 1.0);
    return sqrt(1.0 - k * k);
}

float ease_in_out_circ(float x) {
    return step(x, 0.5) * (1.0 - sqrt(1.0 - 4.0 * x * x) / 2.0)
	+ step(0.5, x) * (sqrt(1.0 - pow(-2.0 * x + 2.0, 2.0)) + 1.0 / 2.0);
}

float ease_in_elastic(float x) {
    const float c4 = (2.0 * PI) / 3.0;
	
	return step(x, 0.0) * (0.0) 
	+ step(x, 1.0) * (1.0) 
	+ step(0.0, x) * (-1.0 * pow(2.0, 10.0 * x - 10.0) * sin((x * 10.0 - 10.75) * c4));
}

float ease_out_elastic(float x) {
	const float c4 = (2.0 * PI) / 3.0;
    return step(x, 0.0) * (0.0)
		+ step(1.0, x) * (1.0)
		+ step(0.0, x) * (pow(2.0, -10.0 * x) * sin((x * 10.0 - 0.75) * c4) + 1.0);
}

float ease_in_out_elastic(float x) {
    const float c5 = (2.0 * PI) / 4.5;
	
	return step(0.0, x) * (0.0)
		+ step(1.0, x) * (1.0)
		+ step(x, 0.5) * (-1.0 * pow(2.0, 20.0 * x - 10.0) * sin((20.0 * x - 11.125) * c5))
		+ step(0.5, x) * (pow(2.0, -20.0 * x + 10.0) * sin((20.0 * x - 11.125) * c5));
}

float ease_in_quad(float x) {
    return x * x;
}

float ease_out_quad(float x) {
    return 1.0 - (1.0 - x) * (1.0 - x);
}

float ease_in_out_quad(float x) {
    return step(x, 0.5) * (2.0 * x * x)
		+ step(0.5, x) * (1.0 - pow(-2.0 * x + 2.0, 2.0) / 2.0);
}

float ease_in_quart(float x) {
    return x * x * x * x;
}

float ease_out_quart(float x) {
    return 1.0 - pow(1.0 - x, 4.0);
}

float ease_in_out_quart(float x) {
    return step(x, 0.5) * (8.0 * x * x * x * x)
		+ step(0.5, x) * (1.0 - pow(-2.0 * x + 2.0, 4.0) / 2.0);
}

float ease_in_expo(float x) {
    return step(x, 0.0) * (0.0)
		+ step(0.001, x) * pow(2.0, 10.0 * x - 10.0);
}

float ease_out_expo(float x) {
    return step(x, 1.0) * (1.0)
		+ step(0.0, x) * (1.0 - pow(2.0, -10.0 * x));
}

float ease_in_out_expo(float x) {
    return step(x, 0.0) * (0.0)
		+ step(1.0, x) * (1.0)
		+ step(x, 0.5) * pow(2.0, 20.0 * x - 10.0) / 2.0
		+ step(0.5, x) * (2.0 - pow(2.0, -20.0 * x + 10.0)) / 2.0;
}

float ease_in_back(float x) {
    const float c1 = 1.70158;
	const float c3 = c1 + 1.0;
	
	return c3 * x * x * x - c1 * x * x;
}

float ease_out_back(float x) {
	const float c1 = 1.70158;
	const float c3 = c1 + 1.0;
    return 1.0 + c3 * pow(x - 1.0, 3.0) + c1 * pow(x - 1.0, 2.0);
}

float ease_in_out_back(float x) {
	const float c1 = 1.70158;
	const float c2 = c1 * 1.525;
	
	return step(x, 0.5) * pow(2.0 * x, 2.0) * ((c2 + 1.0) * 2.0 * x - c2) / 2.0
		+ step(0.5, x) * pow(2.0 * x - 2.0, 2.0) * (((c2 + 1.0) * (x * 2.0 - 2.0) + c2) + 2.0) / 2.0;
}

// depending on where x is located, change what the curve will be
float ease_out_bounce(float x) {
    const float n1 = 7.5625;
	const float d1 = 2.75;
	float j = x;
	
	if (x < 1.0 / d1) {
		return n1 * x * x; // half parabola
	} else if (x < 2.0 / d1) {
		j = x - 1.5 / d1;
		return n1 * j * x + 0.75; // full parabola -- smaller than first if
	} else if (x < 2.5 / d1) { // smallest parabola
		j = x - 2.25 / d1;
		return n1 * j * x + 0.9375;
	}
	
	j = (x - 2.625) / d1;
	return n1 * j * x + 0.984375;
}

float ease_in_bounce(float x) {
    return 1.0 - ease_out_bounce(1.0 - x);
}

float ease_in_out_bounce(float x) {
	return step(x, 0.5) * ((1.0 - ease_out_bounce(1.0 - 2.0 * x)) / 2.0)
		+ step(0.5, x) * ((1.0 + ease_out_bounce(2.0 * x - 1.0)) / 2.0);
}


void fragment() {
	// Called for every pixel the material is visible on.
}
