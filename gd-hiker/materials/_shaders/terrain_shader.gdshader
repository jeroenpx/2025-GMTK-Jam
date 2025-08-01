shader_type spatial;
render_mode diffuse_toon;

uniform vec3 terrain_color: source_color = vec3(1, 1, 1);
uniform vec3 terrain_colorB: source_color = vec3(1, 1, 1);
uniform vec3 terrain_colorC: source_color = vec3(1, 1, 1);
uniform vec3 terrain_color_sides: source_color = vec3(1, 1, 1);
uniform vec3 path_color: source_color = vec3(1, 1, 1);
uniform vec3 path_colorB: source_color = vec3(1, 1, 1);
uniform vec3 emit_color: source_color = vec3(0, 0, 0);

uniform sampler2D path_noise;
uniform float path_noise_scale = 1.0;
uniform float path_step: hint_range(0.0, 1.0, 0.05);
uniform sampler2D path_step_grad: repeat_disable;

uniform sampler2D color_noise;
uniform float color_noise_scale = 1.0;
uniform float color_noise_scale_path = 1.0;

uniform sampler2D color_noise2;
uniform float color_noise2_scale = 1.0;

uniform sampler2D sides_gradient: repeat_disable;

varying vec3 world_position;
varying float sides;

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	sides = 1.0-dot(NORMAL, vec3(0,1,0));
}

void fragment() {
	vec4 sampled_path_noise = texture(path_noise, world_position.xz * path_noise_scale);
	float amount_path = COLOR.r + sampled_path_noise.r;

	float sampled_color_noise = texture(color_noise, world_position.xz * color_noise_scale).r;
	float sampled_color_noise2 = texture(color_noise2, world_position.xz * color_noise2_scale).r;
	float sampled_color_noise_path = texture(color_noise, world_position.xz * color_noise_scale_path).r;

	vec3 terrain = mix(terrain_color, terrain_colorB, sampled_color_noise);
	terrain = mix(terrain, terrain_colorC, sampled_color_noise2);
	vec3 path = mix(path_color, path_colorB, sampled_color_noise_path);

	float sides_grad = texture(sides_gradient, vec2(sides, 0)).r;

	float stepped = 0.0;
	stepped = texture(path_step_grad, vec2(amount_path/2.0, 0)).r;
	//stepped = step(path_step, amount_path);
	ALBEDO = mix(mix(terrain, terrain_color_sides, sides_grad), path, stepped);
	//
	//ALBEDO = mix(terrain_color, path_color, COLOR.r);
	EMISSION = emit_color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
