class_name Character
extends CharacterBody3D

# The model, useful to check the orientation of the 3D model
@export var model: CharacterPivot;

# Signals
signal on_moved;
signal on_jump;
signal on_jump_air;
signal on_jump_ground;


# State
var jumping: bool = false;
var move_blend: Vector2 = Vector2(0, 0);

var next_impulse: Impulse;

func get_impulse() -> Impulse:
	return next_impulse;

func reset_impulse() -> void:
	next_impulse = null;

func set_impulse(impulse: Impulse) -> void:
	next_impulse = impulse;
