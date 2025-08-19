class_name FroggyPlacement
extends Node3D
@onready var animator:AnimationPlayer = $frog/AnimationPlayer
@onready var loop_manager : LoopManager = %LoopManager
var is_disappearing = false
var direction =  Vector3.ZERO
func _ready() -> void:
	visible = false;
	if get_parent() is PointOfInterest:
		(get_parent() as PointOfInterest).froggy_placement = self
	animator.play("Idle")
	loop_manager.on_going_at.connect(froggy_appears)
	loop_manager.on_leaving_from.connect(froggy_disappears)


func froggy_appears(currentPoint: PointOfInterest) -> void:
	if currentPoint.froggy_placement == self:
		visible = true
		animator.play("ArriveJump")
		return
	is_disappearing = false
	visible = false

func froggy_disappears(previousPoint: PointOfInterest, currentPoint: PointOfInterest) -> void:
	if previousPoint.froggy_placement == self:
		is_disappearing = true
		direction = (currentPoint.position - previousPoint.position).normalized() #transform.basis.z
		animator.play("WalkABitLoop")
		return
	visible = false

func _process(delta: float) -> void:
	if is_disappearing:
		position += direction * 2.0 * delta


func move() -> void:
	
	pass
