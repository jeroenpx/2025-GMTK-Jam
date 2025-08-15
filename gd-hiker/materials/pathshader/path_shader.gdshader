shader_type spatial;

uniform vec4 color: source_color = vec4(1, 1, 1, 0);
uniform vec4 color2: source_color = vec4(1, 1, 1, 0);
uniform sampler2D text;

uniform sampler2D time_curve: repeat_enable;
uniform float time_speed = 1.0;
uniform float time_distance = 6.0;
uniform float time_hard_step = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float anim_position = mix(UV.x, floor(UV.x), time_hard_step);
	
	vec4 time_sample = texture(time_curve, vec2((anim_position + TIME * time_speed) / time_distance, 0));
	
	vec4 sample = texture(text, UV) * mix(color, color2, 1.0 - time_sample.r);
	
	ALBEDO = sample.rgb;
	ALPHA = sample.a * time_sample.a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
