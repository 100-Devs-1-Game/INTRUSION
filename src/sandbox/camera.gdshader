shader_type canvas_item;

uniform vec2 u_screen_size = vec2(1920.0, 1080.0);
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float u_desaturate : hint_range(0.0, 1.0) = 0.9;
uniform vec3 u_tint = vec3(0.6, 0.9, 0.6);
uniform float u_contrast : hint_range(0.0, 3.0) = 1.1;
uniform float u_brightness : hint_range(-1.0, 1.0) = 0.0;

uniform float u_scanline_strength : hint_range(0.0, 2.0) = 0.35;
uniform float u_scanline_density : hint_range(1.0, 400.0) = 240.0;
uniform float u_scanline_speed : hint_range(-10.0, 10.0) = 0.8;

uniform float u_noise_strength : hint_range(0.0, 1.0) = 0.12;
uniform float u_noise_scale : hint_range(0.1, 10.0) = 3.0;

uniform float u_vignette : hint_range(0.0, 2.0) = 0.85;
uniform float u_chromatic : hint_range(0.0, 0.05) = 0.008;

uniform float u_glitch_strength : hint_range(0.0, 1.0) = 0.0;
uniform float u_glitch_speed : hint_range(0.0, 10.0) = 0.0;

uniform float u_roll_speed : hint_range(-2.0, 2.0) = 0.0;
uniform float u_flicker_amount : hint_range(0.0, 1.0) = 0.12;
uniform float u_time_mult : hint_range(0.0, 5.0) = 1.0;

float hash(vec2 p) {
	p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
	return -1.0 + 2.0 * fract(sin(p.x + p.y) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f*f*(3.0-2.0*f);
	float a = hash(i + vec2(0.0,0.0));
	float b = hash(i + vec2(1.0,0.0));
	float c = hash(i + vec2(0.0,1.0));
	float d = hash(i + vec2(1.0,1.0));
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

vec3 rgb_to_gray(vec3 c) {
	return vec3(dot(c, vec3(0.299, 0.587, 0.114)));
}

vec3 adjust_contrast_brightness(vec3 c, float contrast, float brightness) {
	c = (c - 0.5) * contrast + 0.5;
	c += brightness;
	return clamp(c, 0.0, 1.0);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	float t = TIME * u_time_mult;

	uv.y += t * u_roll_speed / u_screen_size.y;

	float glitch = u_glitch_strength;
	if (glitch > 0.0001) {
		float gtime = t * (1.0 + u_glitch_speed * 5.0);
		float bands = 6.0 + floor(fract(sin(gtime * 12.345) * 10.0) * 6.0);
		float band_index = floor(uv.y * bands);
		float band_noise = noise(vec2(band_index, floor(gtime)));
		float offset = (band_noise - 0.5) * glitch * 0.08;
		uv.x += offset;
	}

	vec2 ca_dir = normalize(vec2(uv.x - 0.5, uv.y - 0.5) + vec2(0.0001, 0.0001));
	vec2 ca_offset = ca_dir * u_chromatic;

	vec3 col_r = texture(SCREEN_TEXTURE, uv + ca_offset).rgb;
	vec3 col_g = texture(SCREEN_TEXTURE, uv).rgb;
	vec3 col_b = texture(SCREEN_TEXTURE, uv - ca_offset).rgb;
	vec3 col = vec3(col_r.r, col_g.g, col_b.b);

	vec3 gray = rgb_to_gray(col);
	col = mix(col, gray, u_desaturate);
	col = mix(col, u_tint, u_desaturate * 0.6);

	float scan_y = uv.y * u_screen_size.y;
	float scan = sin((scan_y / (u_screen_size.y / u_scanline_density)) * 3.14159 + t * u_scanline_speed);
	scan = smoothstep(0.0, 1.0, scan);
	col *= 1.0 - (scan * u_scanline_strength);

	float n = noise(uv * u_noise_scale * (1.0 + sin(t * 2.0) * 0.2));
	col += (n - 0.5) * u_noise_strength;

	float flick = (sin(t * 60.0 * (0.5 + fract(sin(t*7.0)*100.0))) * 0.5 + 0.5);
	col *= 1.0 + (flick - 0.5) * 2.0 * u_flicker_amount;

	vec2 centered = uv - vec2(0.5);
	float dist = length(centered);
	float vig = smoothstep(0.8, 0.3, dist);
	col *= mix(1.0, vig, u_vignette);

	col = adjust_contrast_brightness(col, u_contrast, u_brightness);

	COLOR = vec4(col, texture(SCREEN_TEXTURE, uv).a);
}
