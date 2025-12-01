shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float u_master_strength : hint_range(0.0, 1.0) = 1.0;
uniform float u_glitch_intensity : hint_range(0.0, 1.0) = 0.45;
uniform float u_slice_count : hint_range(4.0, 128.0) = 24.0;
uniform float u_block_amount : hint_range(0.0, 1.0) = 0.35;
uniform float u_block_size : hint_range(2.0, 64.0) = 8.0;
uniform float u_chroma : hint_range(0.0, 0.2) = 0.03;
uniform float u_flicker_speed : hint_range(0.1, 10.0) = 2.5;
uniform float u_flicker_intensity : hint_range(0.0, 1.0) = 0.7;
uniform float u_burst_rate : hint_range(0.1, 4.0) = 1.2;
uniform float u_burst_strength : hint_range(0.0, 2.0) = 1.2;

float seed(vec2 p, float t) {
	return fract(sin(dot(p, vec2(127.1, 311.7)) + t) * 43758.5453);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 tex_size = vec2(textureSize(SCREEN_TEXTURE, 0));
	float t = TIME;

	float slices = max(1.0, floor(u_slice_count));
	float y_idx_f = floor(uv.y * slices);

	float slice_phase = seed(vec2(y_idx_f, 0.0), t * 0.7);
	float slice_mask = step(0.6, fract(sin(y_idx_f * 12.9898 + t * 1.7) * 43758.5453));
	float slice_offset = (fract(sin((y_idx_f * 7.3) + t * 1.2) * 43758.5453) - 0.5)
		* u_glitch_intensity * 0.25 * u_master_strength;
	float burst = step(0.92, fract(sin(t * u_burst_rate + y_idx_f * 3.33) * 43758.5453))
		* u_burst_strength * u_master_strength;
	slice_offset += (fract(sin(y_idx_f * 19.7 + t * 2.9) * 43758.5453) - 0.5) * burst * 0.3;
	float do_slice = mix(0.0, 1.0, slice_mask * step(0.2, slice_phase));
	uv.x += slice_offset * do_slice;

	vec2 block_uv = uv * tex_size / u_block_size;
	vec2 block_idx = floor(block_uv);
	vec2 block_frac = fract(block_uv);

	vec2 block_shift = (vec2(
		fract(sin(block_idx.x * 12.989 + t * 3.7) * 43758.5453),
		fract(sin(block_idx.y * 78.233 + t * 1.9) * 43758.5453)
	) - 0.5) * u_block_amount * u_glitch_intensity * 0.08 * u_master_strength;

	float block_burst = step(0.94, fract(sin((block_idx.x + block_idx.y) * 5.7 + t * 4.0) * 43758.5453));
	block_shift += (vec2(
		fract(sin(block_idx.x * 3.7 + t * 2.1) * 43758.5453) - 0.5,
		fract(sin(block_idx.y * 5.9 + t * 1.3) * 43758.5453) - 0.5
	)) * block_burst * u_burst_strength * 0.18 * u_master_strength;

	vec2 displaced_uv = (block_idx + block_frac + block_shift) * (u_block_size / tex_size);
	uv = mix(uv, displaced_uv, u_block_amount * u_glitch_intensity * u_master_strength);

	float chroma_drive = (0.5 + 0.5 * sin(t * 3.0)) * u_chroma * u_master_strength;
	float burst_chroma = step(0.9, fract(sin(t * u_burst_rate * 1.7) * 43758.5453))
		* u_burst_strength * 0.02 * u_master_strength;
	float chroma = chroma_drive + burst_chroma;
	vec2 chroma_offset = vec2(chroma * (fract(sin((uv.y + uv.x) * 12.3 + t) * 43758.5453) - 0.5), 0.0);

	vec3 col;
	col.r = texture(SCREEN_TEXTURE, uv + chroma_offset).r;
	col.g = texture(SCREEN_TEXTURE, uv).g;
	col.b = texture(SCREEN_TEXTURE, uv - chroma_offset).b;

	float scan = fract(uv.y * tex_size.y * 0.5 + t * u_flicker_speed);
	float flick = mix(1.0, 0.0, smoothstep(0.0, 0.1, scan * (1.0 - u_flicker_intensity)));
	float global_flicker = mix(1.0, 0.0, step(0.95, fract(sin(t * 5.0) * 43758.5453)) * 0.8 * u_flicker_intensity);
	col *= mix(1.0, clamp(flick * global_flicker, 0.0, 1.0), u_master_strength);

	float burst_now = step(0.88, fract(sin(t * u_burst_rate * 1.3) * 43758.5453));
	float dx = uv.x - 0.5;
	float dy = uv.y - 0.5;
	float dist = sqrt(dx * dx + dy * dy);
	col *= mix(1.0, 0.7, burst_now * smoothstep(0.3, 0.9, dist) * u_master_strength);

	COLOR = vec4(col, 1.0);
}
