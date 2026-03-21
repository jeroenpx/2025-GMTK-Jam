extends Node

@export var root: Node3D;
@export var location_start: Node3D;

@export var loop_manager : LoopManager;

var froggy_display: Character;

var is_disappearing = false
var direction =  Vector3.ZERO
var default_rotation : Vector3
var default_rotation_froggy : Vector3

func _ready() -> void:
	froggy_display = get_tree().get_nodes_in_group("froggy")[0] as Character;
	
	# Move the froggy out of the start location (easier to remap locations
	froggy_display.model.rotation.y = froggy_display.global_rotation.y;
	#root.add_child(froggy_display);
	froggy_display.global_rotation = Vector3(0,0,0);
	
	# Animation stuff
	froggy_display.animator.stop();
	froggy_display.animator.play("Idle")
	default_rotation_froggy = froggy_display.rotation
	default_rotation = froggy_display.get_parent_node_3d().rotation
	loop_manager.on_going_at.connect(froggy_appears)
	loop_manager.on_leaving_from.connect(froggy_disappears)

func _on_froggy_inside_car_act() -> void:
	froggy_display.visible = false;


func _on_froggy_exit_car_act() -> void:
	froggy_display.visible = true;


func froggy_appears(currentPoint: PointOfInterest) -> void:
	reset_transform()
	if currentPoint.name == "Parked":
		froggy_display.visible = true
		froggy_display.animator.stop();
		froggy_display.animator.play("ArriveJump")
		is_disappearing = false;
		return
	else:
		if froggy_display.visible and not is_disappearing:
			froggy_display.visible = false
	
	is_disappearing = false
	froggy_display.visible = false

func froggy_disappears(previousPoint: PointOfInterest, currentPoint: PointOfInterest) -> void:
	if previousPoint.name == "Parked":
		is_disappearing = true
		var currentPosition = currentPoint.position
		var pathCoords: Array
		if previousPoint.paths_3D.has(currentPoint):
			pathCoords = previousPoint.paths_3D[currentPoint]
			direction = (pathCoords[4] - froggy_display.global_position).normalized()
			print("go to coordinates " + str(pathCoords[4]))
			#froggy_display.get_parent_node_3d().global_rotation = Vector3.ZERO;
			froggy_display.look_at(froggy_display.global_position + direction, Vector3.UP);
			froggy_display.global_rotation = froggy_display.rotation;
			froggy_display.rotate_y(deg_to_rad(180))
			froggy_display.animator.stop();
			froggy_display.animator.play("WalkABitLoop")
		else:
			is_disappearing = false
			froggy_display.visible = false
	
		
		return
	
	froggy_display.visible = false

func _process(delta: float) -> void:
	if is_disappearing:
		froggy_display.global_position += direction * 2.0 * delta


func reset_transform() -> void:
	froggy_display.get_parent_node_3d().rotation = default_rotation
	froggy_display.position = Vector3.ZERO
	froggy_display.rotation = default_rotation_froggy
	pass
