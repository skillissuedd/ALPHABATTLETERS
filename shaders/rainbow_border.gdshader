shader_type canvas_item;

uniform float brightness = 0.8;     // яркость рамки
uniform float contrast = 0.9;       // контраст рамки
uniform float alpha_mult = 0.8;     // прозрачность рамки
uniform float border_size = 0.2;
uniform float speed = 0.04;
uniform bool is_active = false;

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	if (is_active) {



	vec2 uv = UV;

	// Проверяем: находимся ли мы в рамке?
	bool is_border = uv.x < border_size || uv.x > (1.0 - border_size)
				  || uv.y < border_size || uv.y > (1.0 - border_size);

	if (is_border) {
		float t = mod(uv.x + uv.y + TIME * speed, 1.0);
		vec3 color = hsv2rgb(vec3(t, 1.0, 1.0));

		// Применяем яркость и контраст к цвету рамки
		color *= brightness;
		color = (color - 0.5) * contrast + 0.5;

		COLOR = vec4(color, alpha_mult);
	} else {
		COLOR = vec4(0.0);

	}
}
}