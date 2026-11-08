shader_type spatial;
render_mode diffuse_burley;
varying vec3 ground_position;
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
 vec2 c = floor(p), f = fract(p); f = f * f * (3.0 - 2.0 * f);
 return mix(mix(hash(c), hash(c + vec2(1, 0)), f.x), mix(hash(c + vec2(0, 1)), hash(c + vec2(1, 1)), f.x), f.y);
}
void vertex() { ground_position = (MODEL_MATRIX * vec4(VERTEX, 1)).xyz; }
void fragment() {
 vec2 p = ground_position.xz;
 float broad = noise(p * 0.11 + noise(p * 0.31));
 float silt = smoothstep(0.38, 0.74, noise(p * 0.34) * 0.6 + broad * 0.4);
 vec3 sand = mix(vec3(0.34, 0.245, 0.15), vec3(0.53, 0.415, 0.28), broad);
 sand = mix(sand, vec3(0.29, 0.25, 0.20), silt * 0.48);
 float track = 1.0 - smoothstep(1.2, 2.6, abs(p.y - (2.0 + sin(p.x * 0.17))));
 float west = 1.0 - smoothstep(-10.0, -4.0, p.x);
 sand = mix(sand, vec3(0.41, 0.33, 0.23), track * west * 0.4);
 float runoff = (1.0 - smoothstep(1.2, 4.5, length((p - vec2(-17, -9.5)) * vec2(0.65, 1.0)))) * (0.65 + noise(p * 1.7) * 0.35);
 sand = mix(sand, vec3(0.20, 0.245, 0.205), runoff * 0.67);
 float ripple = sin(dot(p, vec2(3.2, 11.0)) + noise(p * 0.5) * 8.0) * 0.005;
 ALBEDO = sand + ripple + (noise(p * 24.0) - 0.5) * 0.018;
 ROUGHNESS = 0.98;
}
