@icon("res://systems/characterbase/icons/route-solid.svg")
class_name CharacterMovementInputProvider
extends Node

func calculate(delta: float) -> void:
	pass

# Get movement input in rotation space
func get_move_direction() -> Vector2:
	return Vector2(0, 0);

# Which direction do we want to face?
func get_target_forward_angle() -> float:
	return 0;

# Do we want to jump?
func wants_to_jump() -> bool:
	return false;

# Whether we are attached to something? (wall hanging)
func is_attached() -> bool:
	return false;

func attached_at_position() -> Vector3:
	return Vector3(0,0,0);

# Helper function
static func forward_dir_to_angle(dir: Vector2) -> float:
	return -dir.angle() - PI/2.0;
