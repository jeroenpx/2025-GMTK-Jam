class_name CharacterMovementGravity
extends Step

@export_category("Links")
@export var me: Character;
@export var mv: CharacterMovement;

@export_category("Settings")
@export var gravity_down: float = 1.5;

func step(delta: float) -> void:
	if mv.input_provider.is_attached():
		return;
	
	var gravity_factor = 1;
	if me.velocity.y < 0:
		gravity_factor = gravity_down;
	me.velocity.y += -mv.gravity * gravity_factor * mv._acceleration_correction * delta;
