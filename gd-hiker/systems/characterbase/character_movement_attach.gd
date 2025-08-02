extends Step

@export_category("Links")
@export var me: Character;
@export var mv: CharacterMovement;

@export_category("Settings")
@export var attach_correction_factor: float = 0.7;

func step(delta: float) -> void:
	if not mv.input_provider.is_attached():
		# This type of movement only works when attached
		return;
	
	me.velocity = (mv.input_provider.attached_at_position() - me.global_position) * attach_correction_factor / delta;
