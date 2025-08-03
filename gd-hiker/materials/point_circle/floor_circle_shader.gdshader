shader_type spatial;
render_mode unshaded;

uniform vec4 color: source_color;
uniform sampler2D edge: repeat_disable;

uniform sampler2D noise;
uniform vec2 polar_uv_scale = vec2(1, 1);

uniform float time_speed = 1;

global uniform vec4 circle_color_global;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Convert to polar coords
	vec2 polar = vec2(length(UV), atan(UV.y, UV.x));
	
	vec4 sample = texture(edge, vec2(polar.x, 0)) * color;
	
	float noise_sample = texture(noise, polar * polar_uv_scale + vec2(TIME * time_speed, 0)).r;
	
	// Called for every pixel the material is visible on.
	ALBEDO = sample.rgb * circle_color_global.rgb;
	ALPHA = sample.a * noise_sample;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
