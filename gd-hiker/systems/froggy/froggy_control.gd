extends Node

@export var root: Node3D;
@export var location_start: Node3D;

var froggy_display: Character;

func _ready() -> void:
	froggy_display = get_tree().get_nodes_in_group("froggy")[0] as Character;
	
	# Move the froggy out of the start location (easier to remap locations
	froggy_display.model.rotation.y = froggy_display.global_rotation.y;
	root.add_child(froggy_display);
	froggy_display.global_rotation = Vector3(0,0,0);

func _on_froggy_inside_car_act() -> void:
	froggy_display.visible = false;


func _on_froggy_exit_car_act() -> void:
	froggy_display.visible = true;
