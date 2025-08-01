extends Node3D
@export var camera: Camera3D 
@export var ray_distance: float = 1000.0
@export var current_visit: PointOfInterest = null
@export var number_of_undos: int = 500
@export var limitations: Array[Limitations] = []
var points_of_interest: Array[PointOfInterest] = []
var last_hover_over: Node3D
var visited_paths = []
var current_num_of_undos: int = 0
var start_point: PointOfInterest = null
var is_level_finished: bool = false
var all_limitations_completed: Array[bool] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_point = current_visit
	var temp = get_tree().get_nodes_in_group("point of interest")
	for point in temp:
		if point is PointOfInterest:
			points_of_interest.append(point)
	for i in range(0, limitations.size()):
		all_limitations_completed.append(false)
		


func _process(delta: float) -> void:
	if !is_level_finished:
		hover_over()

#handle the input
func _unhandled_input(event: InputEvent) -> void:
	if !is_level_finished:
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
						update_status(current_visit)
						visited_paths.append(current_path)
						print("From " + str(previous_visit.identifier) + " to " + str(current_visit.identifier))
						if current_visit == start_point:
							if are_all_limitations_completed():
								is_level_finished = true
								print("Return to start- hurray - End Level")
							else:
								BtnIndicators.show_undo(true)
								BtnIndicators.show_reset(true)
						elif !current_visit.is_any_neighbour_available():
							BtnIndicators.show_undo(true)
							BtnIndicators.show_reset(true)
				else:
					print("Don't move. Stay at " + str(current_visit.identifier))
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			undo_path()
		if event.is_action_pressed("reset path"):
			reset_path()


#check if path is already taken
func is_path_taken(current_path: Array[int]) -> bool:
	for path in visited_paths:
		if path.has(current_path[0]) and path.has(current_path[1]):
			print(str(current_path) + " path taken" + str(path))
			return true
	print("path not taken")
	return false

#update the limitation status
func update_status(visit: PointOfInterest)-> void:
	var i : int = 0
	for limitation in limitations:
		if limitation.visit_type == visit.type_point_of_interest:
			limitation.value -=1
			print("Limit " + str(limitation.visit_type) + " " + str(limitation.value))
			match limitation.numerical_type:
				Limitations.NumericalType.MIN:
					if limitation.value <= 0:
						all_limitations_completed[i] = true
						print("minimun okay")
					else:
						all_limitations_completed[i] = false
						print("minimun not okay")
				Limitations.NumericalType.MAX:
					if limitation.value >= 0:
						all_limitations_completed[i] = true
						print("max okay")
					else:
						all_limitations_completed[i] = false
						print("max not okay")
				Limitations.NumericalType.CONSTANT:
					if limitation.value == 0:
						all_limitations_completed[i] = true
						print("const okay")
					else:
						all_limitations_completed[i] = false
						print("const not okay")
		i+=1


#check if all limitations are completed
func are_all_limitations_completed() -> bool:
	for is_complete in all_limitations_completed:
		if !is_complete:
			return false
	return true




#undo path
func undo_path() -> void:
	
	BtnIndicators.show_undo(false)
	BtnIndicators.show_reset(false)
		
	var last_path = visited_paths.pop_back()
	if last_path:
		points_of_interest[last_path[1]].undo_point_of_interest()
		current_visit = points_of_interest[last_path[0]]
		print("current visit = " + str(current_visit.identifier))
		#Spawn player at node current_visit

#reset path
func reset_path() -> void:
	BtnIndicators.show_reset(false)
	BtnIndicators.show_undo(false)
	visited_paths.clear()
	current_visit = start_point
	current_num_of_undos = 0
	print("Reset - current visit = " + str(current_visit.identifier))
	for point in points_of_interest:
		point.is_visited = false

#hover over functionality
func hover_over() -> void:
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mouse_pos)
	var end = origin + camera.project_ray_normal(mouse_pos)*ray_distance
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	
	var hit = space_state.intersect_ray(query)
	if hit:
		var point = hit.collider
		if point != last_hover_over:
			if last_hover_over:
				print("mouse exited " + last_hover_over.name)
			print("mouse enter " + point.name)
			last_hover_over = point
			if point.can_visit(current_visit.identifier):
				var current_path: Array[int] = [current_visit.identifier, point.identifier]
				if !is_path_taken(current_path):
					point.hover_over(true)
				else:
					point.hover_over(false)
	else:
		if last_hover_over:
			print("mouse exited " + last_hover_over.name)
			last_hover_over.hover_over(false)
			last_hover_over = null
