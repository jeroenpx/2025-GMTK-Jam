class_name CircleEffect
extends MeshInstance3D

enum State {
	VISITED,
	VISIT_OPTION,
	VISIT_OPTION_HOVER,
	AVAILABLE
}

@export var state: State = State.AVAILABLE;

@export var material_options: Dictionary[State, Material];

func _update_state ():
	material_override = material_options[state];

func _ready() -> void:
	_update_state();

func set_state(state: State):
	self.state = state;
	_update_state();
