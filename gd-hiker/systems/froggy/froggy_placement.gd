class_name FroggyPlacement
extends Node3D

func _ready() -> void:
	visible = false;
	if get_parent() is PointOfInterest:
		(get_parent() as PointOfInterest).froggy_placement = self;
