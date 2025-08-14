class_name FroggyPlacement
extends Node3D
@onready var animator:AnimationPlayer = $frog/AnimationPlayer
@onready var loop_manager : LoopManager = %LoopManager
func _ready() -> void:
	visible = false;
	if get_parent() is PointOfInterest:
		(get_parent() as PointOfInterest).froggy_placement = self
	animator.play("Idle")
	loop_manager.on_going_at.connect(froggy_appears)


func froggy_appears(currentPoint: PointOfInterest) -> void:
	if currentPoint.froggy_placement == self:
		visible = true
		animator.play("Idle")
		return
	visible = false
