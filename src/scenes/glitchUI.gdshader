shader_type canvas_item;

uniform float glitch_amount : hint_range(0.0, 1.5) = 0.0;
uniform float rgb_amount : hint_range(0.0, 1.5) = 1.0;
uniform float speed : hint_range(0.0, 8.0) = 1.2;
uniform float scanline_strength : hint_range(0.0, 0.5) = 0.06;
uniform float rgb_offset_px : hint_range(0.0, 12.0) = 4.0;
uniform float block_chance : hint_range(0.0, 1.0) = 0.08;
uniform float block_max_frac : hint_range(0.0, 0.4) = 0.12;
uniform float noise_strength : hint_range(0.0, 0.5) = 0.06;
uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

float hash21(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 uv) {
	vec2 i = floor(uv);
	vec2 f = fract(uv);
	float a = hash21(i + vec2(0.0,0.0));
	float b = hash21(i + vec2(1.0,0.0));
	float c = hash21(i + vec2(0.0,1.0));
	float d = hash21(i + vec2(1.0,1.0));
	vec2 u = f*f*(3.0-2.0*f);
	return mix(a,b,u.x) + (c-a)*u.y*(1.0-u.x) + (d-b)*u.x*u.y;
}

vec4 sample_screen(vec2 uv){
	return texture(SCREEN_TEXTURE, uv);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 texSize = vec2(textureSize(SCREEN_TEXTURE, 0));
	float px = 1.0 / texSize.x;
	float t = TIME * speed;

	float g = clamp(glitch_amount, 0.0, 1.0);
	float r = clamp(rgb_amount, 0.0, 1.0);

	float jitter = sin((uv.y * texSize.y * 0.5) + t * 8.0) * (0.02 * g);
	uv.x += jitter * (0.6 + 0.4 * sin(t * 0.7));

	vec2 grid = uv * vec2(32.0, 12.0);
	vec2 cell = floor(grid);
	float rnd = hash21(cell + vec2(floor(t), 0.0));
	if (rnd < block_chance * g) {
		vec2 local = fract(grid);
        float h = mix(0.02, block_max_frac, hash21(cell + 1.0)) * g;
		float w = mix(0.03, block_max_frac, hash21(cell + 2.0)) * g;
		vec2 pos = vec2(hash21(cell + 3.0), hash21(cell + 4.0));
		vec2 rectMin = pos;
		vec2 rectMax = pos + vec2(w, h);
		if (uv.x > rectMin.x && uv.x < rectMax.x && uv.y > rectMin.y && uv.y < rectMax.y) {
			uv.x += (hash21(cell + 5.0) - 0.5) * 0.14 * g;
			uv.y += (hash21(cell + 6.0) - 0.5) * 0.02 * g;
		}
	}

	vec2 rgb_off = vec2(rgb_offset_px * px * rgb_amount, 0.0);
	vec4 cr = sample_screen(uv + rgb_off * 1.0);
	vec4 cg = sample_screen(uv + rgb_off * -0.6);
	vec4 cb = sample_screen(uv + rgb_off * 0.2);
	vec3 chroma = vec3(cr.r, cg.g, cb.b);

	vec4 base = sample_screen(uv);
	float scan = sin((uv.y * texSize.y * 1.5) + t * 20.0) * scanline_strength * g;
	base.rgb += scan;

	float n = noise(uv * texSize.xy * 0.5 + vec2(t * 2.3, t));
	chroma += (n - 0.5) * noise_strength * g;

	vec3 outc = mix(base.rgb, chroma, smoothstep(0.0, 1.0, rgb_amount));

	float pulse = smoothstep(0.9, 1.0, fract(sin(t * 12.3) * 43758.54)) * 0.12 * g * flash_amount;
	outc += pulse;

	COLOR = vec4(outc, base.a);
}
