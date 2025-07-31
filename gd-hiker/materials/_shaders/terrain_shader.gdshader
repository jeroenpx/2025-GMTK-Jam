shader_type spatial;

uniform vec3 terrain_color: source_color = vec3(1, 1, 1);
uniform vec3 path_color: source_color = vec3(1, 1, 1);

uniform sampler2D path_noise;
uniform float path_noise_scale;
uniform float path_step: hint_range(0.0, 1.0, 0.05);

varying vec3 world_position;

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec4 sampled_path_noise = texture(path_noise, world_position.xz * path_noise_scale);
	
	float amount_path = COLOR.r + sampled_path_noise.r;
	
	ALBEDO = mix(terrain_color, path_color, step(path_step, amount_path));
	// 
	//ALBEDO = mix(terrain_color, path_color, COLOR.r);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
