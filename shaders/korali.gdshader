shader_type spatial;
render_mode diffuse_burley;
varying vec3 local_position;

vec3 hash3(vec3 p) {
	return fract(sin(vec3(dot(p, vec3(127.1, 311.7, 74.7)),
		dot(p, vec3(269.5, 183.3, 246.1)),
		dot(p, vec3(113.5, 271.9, 124.6)))) * 43758.5453);
}

void vertex() { local_position = VERTEX; }

void fragment() {
	vec3 p = local_position * 1.35;
	p += vec3(sin(p.y * 3.4), sin(p.z * 3.1), sin(p.x * 2.7)) * 0.12;
	vec3 cell = floor(p);
	vec3 f = fract(p);
	float first = 10.0;
	float second = 10.0;
	for (int x = -1; x <= 1; x++) {
		for (int y = -1; y <= 1; y++) {
			for (int z = -1; z <= 1; z++) {
				vec3 neighbor = vec3(float(x), float(y), float(z));
				float distance = length(neighbor + hash3(cell + neighbor) - f);
				if (distance < first) { second = first; first = distance; }
				else if (distance < second) { second = distance; }
			}
		}
	}
	float edge = second - first;
	float seam = 1.0 - smoothstep(0.018, 0.058, edge);
	float rim = 1.0 - smoothstep(0.04, 0.09, edge);
	float grain = hash3(floor(local_position * 28.0)).x;
	vec3 rock = mix(vec3(0.09, 0.13, 0.14), vec3(0.24, 0.26, 0.24), grain);
	vec3 metal = mix(vec3(0.03, 0.49, 0.42), vec3(0.29, 0.79, 0.72), sin(p.y * 4.0 + p.x) * 0.5 + 0.5);
	ALBEDO = mix(mix(rock, vec3(0.42, 0.29, 0.12), rim * 0.7), metal, seam);
	EMISSION = metal * seam * 0.22;
	METALLIC = seam * 0.55;
	ROUGHNESS = mix(0.9, 0.32, seam);
}
