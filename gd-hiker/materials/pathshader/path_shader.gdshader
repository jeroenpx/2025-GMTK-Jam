shader_type spatial;

uniform vec4 color: source_color = vec4(1, 1, 1, 0);
uniform vec4 color2: source_color = vec4(1, 1, 1, 0);
uniform vec4 color_disabled: source_color = vec4(1, 1, 1, 0);
uniform vec4 color_taken: source_color = vec4(1, 1, 1, 0);
uniform vec4 color_taken2: source_color = vec4(1, 1, 1, 0);
uniform sampler2D text;

// AVAIALABLE PATH STATE
uniform sampler2D time_curve: repeat_enable;
uniform float time_speed = 1.0;
uniform float time_distance = 6.0;
uniform float time_hard_step = 1.0;
instance uniform float time_flip = 1.0;

// BECOME AVAILABLE PATH STATE
uniform sampler2D activation_curve: repeat_disable;
instance uniform float activation_distance = 10.0;
uniform float activation_length = 12.0;

// DISABLE
instance uniform float disable_amount: hint_range(0.0, 1.0, 0.01) = 0.0;

// TAKE THE PATH STATE
uniform sampler2D taken_curve: repeat_disable;
instance uniform float taken_distance = 0.0;
uniform float taken_length = 12.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// ANIMATION POSITION
	float anim_position = mix(UV.x, floor(UV.x), time_hard_step);
	
	
	// "ACTIVE WALKING ACTIVATION"
	float activated = activation_distance - anim_position;
	vec4 activation_sample = texture(activation_curve, vec2(activated / activation_length, 0));
	
	// "TAKEN PATH INDICATION"
	float taken = taken_distance - anim_position;
	vec4 taken_sample = texture(taken_curve, vec2(taken / taken_length, 0));
	
	// "ACTIVE WALKING"
	vec4 time_sample = texture(time_curve, vec2((anim_position + TIME * time_speed * time_flip) / time_distance, 0));
	if (activated < 0.0) {
		time_sample = vec4(0, 0, 0, 0);
	}
	
	// HACK: take out the activation and walking phase
	//activation_sample = vec4(0, 0, 0, 0);
	//time_sample = vec4(0, 0, 0, 0);
	// HACK, use the activation colors for the step
	//time_sample.r = taken_sample.r;
	//taken_sample.r = 0.0;
	
	// FOOTSTEP COLOR
	// 1. active walking & activation
	vec4 step_color = mix(color, color2, 1.0 - max(time_sample.r, activation_sample.r));
	// 2. disable
	step_color = mix(step_color, color_disabled, disable_amount);
	// 3. taken
	step_color = mix(step_color, mix(color_taken, color_taken2, 1.0 - time_sample.r), taken_sample.r);
	
	// FOOTSTEP SHAPE
	vec4 sample = texture(text, UV) * step_color;
	
	// APPLY
	ALBEDO = sample.rgb;
	ALPHA = sample.a * max(max(time_sample.a, activation_sample.a), taken_sample.a);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
