shader_type canvas_item;

const float uv_center = 0.5;
uniform float half_box_area: hint_range(0.0, 0.5) = 0.0;
uniform vec3 box_color: source_color = vec3(0.0);

void fragment() {
	vec2 uv = UV;
	float edge_thickness = uv_center - half_box_area;
	float left = step(edge_thickness, uv.x);
	float right = step(edge_thickness, 1.0 - uv.x);
	float bottom = step(edge_thickness, 1.0 - uv.y);
	float top = step(edge_thickness, uv.y);
	
	float is_shaded = left * right * bottom * top;
	vec3 color = is_shaded * box_color;
	float alpha = is_shaded;
	COLOR = vec4(color, alpha);
}
