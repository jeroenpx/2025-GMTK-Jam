class_name FroggyPlacement
extends Node3D
@onready var animator:AnimationPlayer = $frog/AnimationPlayer
func _ready() -> void:
	visible = false;
	if get_parent() is PointOfInterest:
		(get_parent() as PointOfInterest).froggy_placement = self;
	animator.play("Idle")
