@icon("res://systems/characterbase/icons/person-walking-arrow-right-solid.svg")
class_name CharacterMovement
extends Node

@export_category("Links")
@export var me: Character;
@export var input_provider: CharacterMovementInputProvider;

# Derived settings
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var _acceleration_correction: float;

# Shared State
var no_grip_duraction: float = 0;

func _ready() -> void:
	_acceleration_correction = Math.acceleration_correction(1.0/ProjectSettings.get_setting("physics/common/physics_ticks_per_second"));

func _physics_process(delta):
	if not GameState.shouldRunPhysics():
		return;
	
	input_provider.calculate(delta);
	
	# Move steps
	for step in get_children():
		if step is Step:
			step.step(delta);
	
	# Actually move
	me.move_and_slide();
	
	# Get back grip
	no_grip_duraction -= delta;
	
	me.on_moved.emit();
