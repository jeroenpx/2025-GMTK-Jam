extends Step

@export_category("Links")
@export var me: Character;
@export var mv: CharacterMovement;

func step(delta: float) -> void:
	var impulse: Impulse = me.get_impulse();
	me.reset_impulse();
	if impulse != null:
		mv.no_grip_duraction = maxf(mv.no_grip_duraction, impulse.lost_grip_duration);
		if impulse.impulse.length() < 0.5:
			me.velocity += impulse.impulse;
		else:
			# Impulses OVERWRITE velocity currently
			# I believe that will feel better
			me.velocity = impulse.impulse;
