extends Node3D
@export var camera: Camera3D 
@export var ray_distance: float = 1000.0
@export var current_visit: PointOfInterest = null
@export var number_of_undos: int = 500
var points_of_interest: Array[PointOfInterest] = []

var visited_paths = []
var current_num_of_undos: int = 0
var start_point: PointOfInterest = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_point = current_visit
	var temp = get_tree().get_nodes_in_group("point of interest")
	for point in temp:
		if point is PointOfInterest:
			points_of_interest.append(point)

#handle the input
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var space_state = get_world_3d().direct_space_state
		var mouse_pos = event.position
		var origin = camera.project_ray_origin(mouse_pos)
		var end = origin + camera.project_ray_normal(mouse_pos)*ray_distance
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.collide_with_areas = true
		var hit = space_state.intersect_ray(query)
		if hit:
			var point = hit.collider
			var previous_visit = current_visit
			
			if point.can_visit(previous_visit.identifier):
				var current_path: Array[int] = [previous_visit.identifier, point.identifier]
				if !is_path_taken(current_path):
					current_visit = point.on_clicked(previous_visit)
					visited_paths.append(current_path)
					print("From " + str(previous_visit.identifier) + " to " + str(current_visit.identifier))
					if current_visit == start_point:
						print("Return to start- hurray - End Level")
					elif !current_visit.is_any_neighbour_available():
						print("Undo or Reset")
			else:
				print("Don't move. Stay at " + str(current_visit.identifier))
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		undo_path()
	if event.is_action_pressed("reset path"):
		reset_path()



func is_path_taken(current_path: Array[int]) -> bool:
	for path in visited_paths:
		if path.has(current_path[0]) and path.has(current_path[1]):
			print(str(current_path) + " path taken" + str(path))
			return true
	print("path not taken")
	return false


func undo_path() -> void:
	if(number_of_undos>current_num_of_undos):
		current_num_of_undos += 1
		var last_path = visited_paths.pop_back()
		if last_path:
			points_of_interest[last_path[1]].is_visited = false
			current_visit = points_of_interest[last_path[0]]
			print("current visit = " + str(current_visit.identifier))
			#Spawn player at node current_visit
	else:
		print("no more undos")


func reset_path() -> void:
	visited_paths.clear()
	current_visit = start_point
	current_num_of_undos = 0
	print("Reset - current visit = " + str(current_visit.identifier))
	for point in points_of_interest:
		point.is_visited = false
