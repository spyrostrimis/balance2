shader_type spatial;
render_mode diffuse_burley;

varying vec3 ground_position;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 cell = floor(p);
	vec2 f = fract(p);
	vec2 blend = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(cell), hash(cell + vec2(1.0, 0.0)), blend.x),
		mix(hash(cell + vec2(0.0, 1.0)), hash(cell + vec2(1.0, 1.0)), blend.x), blend.y);
}

void vertex() {
	ground_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = ground_position.xz;
	float variation = noise(p * 0.17) * 0.7 + noise(p * 1.4) * 0.3;
	float grain = noise(p * 28.0) * 0.025;
	float ripples = sin(p.y * 19.0 + noise(p * 0.35) * 7.0) * 0.014;
	ALBEDO = mix(vec3(0.40, 0.28, 0.17), vec3(0.60, 0.45, 0.28), variation) + grain + ripples;
	ROUGHNESS = 1.0;
}
