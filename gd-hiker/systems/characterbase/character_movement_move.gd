class_name CharacterMovementMove
extends Step

@export_category("Links")
@export var me: Character;
@export var mv: CharacterMovement;

@export_category("Settings")
@export var move_speed: float = 5.0;# in units per second
@export var move_acceleration_to_full_speed: float = 3.0;# in acceleration to 100%
@export var move_limiter_threshold: float = 0.4;
@export var move_keep_sideways: float = 0.1;
@export var rotation_speed: float = 12.0;# in radians per second
@export var max_speed_rotation_reduction: float = 0.0;
@export var air_drag_percent: float = 0.1;
@export var no_drag_percent: float = 0.1;

func step(delta: float) -> void:
	if mv.input_provider.is_attached():
		# This type of movement only works when not attached
		return;
	
	var dir: Vector2 = mv.input_provider.get_move_direction();
	var dir_angle: float = mv.input_provider.get_target_forward_angle();
	
	# Horizontal velocity
	var velocity_horiz_current = Vector2(me.velocity.x, me.velocity.z);
	var target_acceleration: Vector2 = -velocity_horiz_current.normalized();
	var control: float = 1.0;
	
	var drag: float = 1.0;
	if not me.is_on_floor():
		drag = air_drag_percent;
	if mv.no_grip_duraction > 0:
		drag = no_drag_percent;
		control = no_drag_percent;
	target_acceleration = target_acceleration * drag;
	if dir.length() > 0.1:
		target_acceleration = dir * control;
		
		# side-ways drag
		var forward = dir.normalized();
		var right = Vector2(-dir.y, dir.x).normalized();
		
		var side_ways_drag_factor = (1- (1 - move_keep_sideways)*control);
		var forward_overflow_drag_factor = side_ways_drag_factor;
		
		# forward drag still applies if past the max speed
		var forward_speed = velocity_horiz_current.dot(forward);
		var forward_speed_allowed = minf(abs(forward_speed), move_speed);
		var forward_speed_overflow = abs(forward_speed) - forward_speed_allowed;
		
		#var will_kill_side_way_movement_amount = velocity_horiz_current.dot(right) * side_ways_drag_factor;
		# ^ use for animation?
		
		velocity_horiz_current = sign(forward_speed)*(forward_speed_allowed + forward_speed_overflow * forward_overflow_drag_factor)*forward + velocity_horiz_current.dot(right)*right * side_ways_drag_factor;
		
	var velocity_horiz_2D = _roll_movement(velocity_horiz_current, delta, target_acceleration, move_speed, 1.0);
	var velocity_horiz = Vector3(velocity_horiz_2D.x, 0, velocity_horiz_2D.y);
	#var velocity_horiz = lerp(Vector3(me.velocity.x, 0, me.velocity.z), dir * move_speed, acceleration * _acceleration_correction * delta);
	#print(velocity_horiz.length());
	
	# Rotate forward (according to the camera)
	if velocity_horiz.length() > 1.0:
		var percent_to_max_speed: float = velocity_horiz.length() / move_speed;
		#print(percent_to_max_speed);
		me.model.set_pivot_angle(lerp_angle(me.model.get_pivot_angle(), dir_angle, rotation_speed * ((1.0-max_speed_rotation_reduction) * percent_to_max_speed + 1.0-percent_to_max_speed) * mv._acceleration_correction * delta * control))
	
	# Keep vertical velocity
	me.velocity = Vector3(velocity_horiz.x, me.velocity.y, velocity_horiz.z)
	
	# Handle animation
	var vl = velocity_horiz * me.model.transform.basis
	me.move_blend = Vector2(vl.x, -vl.z) / move_speed;


## Quick acceleration (dist = at²), then slowdown (optional) and minor acceleration (optional)
func _roll_movement(input_speed: Vector2, delta: float, acceleration_dir: Vector2, target_move_speed: float, speed_factor: float) -> Vector2:
	# Limit possible acceleration if already going fast in that direction
	var distanceFromMaxSpeedPercent: float = 1.0;
	if acceleration_dir.dot(input_speed) > -0.0:
		distanceFromMaxSpeedPercent = 1.0 - max(0.0, input_speed.length()-move_limiter_threshold*target_move_speed*speed_factor)/((1.0-move_limiter_threshold)*target_move_speed);
		distanceFromMaxSpeedPercent = max(0.0, distanceFromMaxSpeedPercent)
	
	# Sum everything
	var target_acceleration_factor: float = move_acceleration_to_full_speed * distanceFromMaxSpeedPercent;
	
	# Apply outputs
	var output_speed: Vector2 = lerp(input_speed, acceleration_dir * move_speed, target_acceleration_factor * mv._acceleration_correction * delta);
	
	# Reset speed to 0
	if input_speed.dot(output_speed) < 0.0:
		output_speed = Vector2(0.0, 0.0);
	return output_speed;
