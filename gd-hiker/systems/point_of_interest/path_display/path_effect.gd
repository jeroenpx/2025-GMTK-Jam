class_name PathEffect
extends MeshInstance3D

enum State {
	HIDDEN,
	READY,
	TAKEN
}

# PUBLIC STATE

# We finished animating to this state
# NOTE that this might not actually be the state you asked for last.
# E.g. if path becomes available and you instantly take it
# => first the "become available" animation will finish before the state will be "taken"
signal on_animated_to_state(state: State);

# Which state did we complete?
var completed_state: State = State.HIDDEN;
# What state we want to reach finally?
var target_state: State = State.HIDDEN;

# Are we animating? 
# NOTE: even if target_state == completed_state, an animation might still be ongoing
# E.g. happens if you go forward & immediatelly back
var animating: bool = false;

# Hover state
var ready_but_no_hover: bool = false;

# Internal state
var _ready_distance_covered: float = 0;
var _taken_distance_covered: float = 0;
var _disable_amount: float = 0;

# Auto-filled settings
@export_category("Path Details")
# Path length - set by the generation code
# (expressed in hex tiles = expressed in shader UV coordinates)
@export var path_length: float = 0;
@export var path_from: PointOfInterest;
@export var path_to: PointOfInterest;

# Settings
@export_category("Prefab Animation Setting")
@export var move_speed_forwards: float = 10.0;
@export var move_speed_backwards: float = 10.0;
@export var grey_out_speed: float = 10.0;
@export var path_animation_trail_overflow_length: float = 12.0;

# Interact with external stuff
func _path_effect_wants_to_teleport_player_to(point: PointOfInterest) -> void:
	# TODO: teleport the player only when the animation finishes!!!
	#%LoopManager.on_going_at.emit(point);
	pass

# Animate to a certain state
func animate_to_state(state: State) -> bool:
	target_state = state;
	if completed_state == target_state and not animating:
		# Already ok, do nothing
		set_process(false);
		return false;
	else:
		# Start processing the animation
		print("Animating Path: ", name, " from ", completed_state, " to ", target_state);
		set_process(true);
		return true;

func set_ready_but_no_hover(ready_but_no_hover: bool):
	self.ready_but_no_hover = ready_but_no_hover;

# Skip the animation to the end
# NOTE: will no longer trigger the on_animated_to_state signal
# However, the _path_effect_wants_to_teleport_player_to will still be called
func skip_animation():
	var is_skipping_player_move = (target_state == State.TAKEN or completed_state == State.HIDDEN) and (target_state != completed_state or animating);
	
	if target_state == State.HIDDEN:
		_ready_distance_covered = 0;
		_taken_distance_covered = 0;
	elif target_state == State.READY:
		_ready_distance_covered = _anim_path_length()+_activation_delay_path_length();
		_taken_distance_covered = 0;
	elif target_state == State.TAKEN:
		_ready_distance_covered = _anim_path_length()+_activation_delay_path_length();
		_taken_distance_covered = _anim_path_length();
	animating = false;
	completed_state = target_state;
	if target_state == State.HIDDEN:
		visible = false;
	else:
		visible = true;
	set_process(false);
	_update_material();
	
	if is_skipping_player_move:
		if completed_state == State.TAKEN:
			_path_effect_wants_to_teleport_player_to(path_to);
		else:
			_path_effect_wants_to_teleport_player_to(path_from);

func _anim_path_length() -> float:
	return path_length + path_animation_trail_overflow_length;

func _activation_delay_path_length() -> float:
	return path_length + path_animation_trail_overflow_length;

func _ready() -> void:
	if target_state == State.HIDDEN:
		self.visible = false;
		set_process(false);

func _process(delta: float) -> void:
	if not GameState.isGameplayRunning():
		return;
	
	var rescale_speed = _anim_path_length() / 40.0;
	
	var ready_direction = -1.0 * move_speed_backwards * rescale_speed;
	var taken_direction = -1.0 * move_speed_backwards * rescale_speed;
	if target_state == State.READY:
		ready_direction = 1.0 * move_speed_forwards * rescale_speed;
	elif target_state == State.TAKEN:
		ready_direction = 1.0 * move_speed_forwards * rescale_speed;
		taken_direction = 1.0 * move_speed_forwards * rescale_speed;
	if taken_direction > 0.0 and _taken_distance_covered >= _ready_distance_covered - _activation_delay_path_length():
		# Don't take yet if not ready that far yet
		taken_direction = 0.0;
	
	var trigger = false;
	_ready_distance_covered += ready_direction * delta;
	_taken_distance_covered += taken_direction * delta;
	if taken_direction < 0 and _taken_distance_covered < 0 and completed_state == State.TAKEN:
		trigger = true;
		completed_state = State.READY;
		on_animated_to_state.emit(State.READY);
		_path_effect_wants_to_teleport_player_to(path_from);
	if ready_direction < 0 and _ready_distance_covered < 0 and completed_state == State.READY:
		trigger = true;
		completed_state = State.HIDDEN;
		on_animated_to_state.emit(State.HIDDEN);
	if ready_direction > 0 and _ready_distance_covered > _anim_path_length() + _activation_delay_path_length() and completed_state == State.HIDDEN:
		trigger = true;
		completed_state = State.READY;
		on_animated_to_state.emit(State.READY);
	if taken_direction > 0 and _taken_distance_covered > _anim_path_length() and completed_state == State.READY:
		trigger = true;
		completed_state = State.TAKEN;
		on_animated_to_state.emit(State.TAKEN);
		_path_effect_wants_to_teleport_player_to(path_to);
	
	if trigger and target_state == completed_state:
		animating = false;
		set_process(false);
		if completed_state == State.HIDDEN:
			visible = false;
	else:
		animating = true;
		visible = true;
	
	_ready_distance_covered = clampf(_ready_distance_covered, 0.0, _anim_path_length() + _activation_delay_path_length());
	_taken_distance_covered = clampf(_taken_distance_covered, 0.0, _anim_path_length());
	
	if ready_but_no_hover:
		_disable_amount += grey_out_speed * delta;
	else:
		_disable_amount -= grey_out_speed * delta;
	_disable_amount = clampf(_disable_amount, 0.0, 1.0);
	
	_update_material();

func _update_material() -> void:
	set_instance_shader_parameter("activation_distance", clamp(_ready_distance_covered - _activation_delay_path_length(), 0.0, INF));
	set_instance_shader_parameter("taken_distance", _taken_distance_covered);
	set_instance_shader_parameter("time_flip", -1.0 if target_state == State.HIDDEN else 1.0);
	set_instance_shader_parameter("disable_amount", _disable_amount);
