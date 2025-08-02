@icon("res://systems/characterbase/icons/arrows-spin-solid.svg")
class_name CharacterPivot
extends Node3D

func set_pivot_angle(angle: float) -> void:
	self.rotation.y = angle;

func get_pivot_angle() -> float:
	return self.rotation.y;
