shader_type canvas_item;

uniform float speed : hint_range(0.0, 10.0) = 1.0;
uniform float contrast : hint_range(0.0, 2.0) = 1.0;

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    float noise = rand(uv * TIME * speed + TIME);
    noise = (noise - 0.5) * contrast + 0.5;
    COLOR = vec4(vec3(noise), 1.0);
}
