class_name FroggyPlacement
extends Node3D
@onready var animator:AnimationPlayer = $frog/AnimationPlayer
@onready var froggy: Node3D = $frog
@onready var loop_manager : LoopManager = %LoopManager
var is_disappearing = false
var direction =  Vector3.ZERO
var default_rotation : Vector3
var default_rotation_froggy : Vector3


func _ready() -> void:
	visible = false;
	if get_parent() is PointOfInterest:
		(get_parent() as PointOfInterest).froggy_placement = self
	animator.play("Idle")
	default_rotation_froggy = froggy.rotation
	default_rotation = rotation
	loop_manager.on_going_at.connect(froggy_appears)
	loop_manager.on_leaving_from.connect(froggy_disappears)


func froggy_appears(currentPoint: PointOfInterest) -> void:
	reset_transform()
	if currentPoint.froggy_placement == self:
		visible = true
		animator.stop();
		animator.play("ArriveJump")
		is_disappearing = false;
		return
	else:
		if visible and not is_disappearing:
			visible = false
	
	is_disappearing = false
	visible = false

func froggy_disappears(previousPoint: PointOfInterest, currentPoint: PointOfInterest) -> void:
	if previousPoint.froggy_placement == self:
		is_disappearing = true
		var currentPosition = currentPoint.position
		var pathCoords: Array[Vector3]
		if previousPoint.paths_3D.has(currentPoint):
			pathCoords = previousPoint.paths_3D[currentPoint]
			direction = (pathCoords[4] - froggy.global_position).normalized()
			print("go to coordinates " + str(pathCoords[4]))
			froggy.look_at(froggy.global_position + direction, Vector3.UP)
			froggy.rotate_y(deg_to_rad(180))
			animator.stop();
			animator.play("WalkABitLoop")
		else:
			is_disappearing = false
			visible = false
	
		
		return
	
	visible = false

func _process(delta: float) -> void:
	if is_disappearing and not GameState.isGamePaused():
		froggy.global_position += direction * 2.0 * delta


func reset_transform() -> void:
	rotation = default_rotation
	froggy.position = Vector3.ZERO
	froggy.rotation = default_rotation_froggy
	pass
