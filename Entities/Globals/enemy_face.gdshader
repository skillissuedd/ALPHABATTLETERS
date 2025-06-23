shader_type canvas_item;
uniform float fill_amount : hint_range(0, 1) = 1.0;
uniform vec4 fill_color : source_color = vec4(0.9, 0.9, 0.5, 1.0);
uniform vec4 bg_color : source_color = vec4(0.3, 0.2, 0.1, 1.0);

void fragment() {
	if (UV.y < fill_amount) { // Fill from top down
		COLOR = fill_color;
	} else {
		COLOR = bg_color;
	}
}