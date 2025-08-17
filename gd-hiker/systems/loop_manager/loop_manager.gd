class_name LoopManager
extends Node3D

signal on_going_at(current_visit)
signal going_back(current_visit)
signal reset(starting_point)

signal reseting_hover_over()

signal start_hovering_over(visit_pos, visit_spot)
signal stop_hovering_over()

@export var camera: Camera3D 
@export var ray_distance: float = 1000.0
@export var current_visit: PointOfInterest = null
@export var limitations: Array[Limitations] = []

var points_of_interest: Array[PointOfInterest] = []
var last_hover_over: Node3D
var visited_paths = []
var start_point: PointOfInterest = null
var is_level_finished: bool = false
var all_limitations_completed: Array[bool] = []
var limitations_start_values: Array[int] = []
var current_path: Array[PointOfInterest] = []
var is_reseting: bool = false
var is_hovering_over = false
var available_to_visit_from: PointOfInterest;
var available_to_visit: Array[PointOfInterest] = [];
var duo_visit_types: Array[Limitations.VisitType] = [Limitations.VisitType.ZIPLINE, Limitations.VisitType.PIER] #update this when necessary
var last_path_effect_taken: PathEffect;

func _ready() -> void:
	reseting_hover_over.connect(_on_reseting_hover_over)
	start_point = current_visit
	var temp = get_tree().get_nodes_in_group("point of interest")
	for point in temp:
		if point is PointOfInterest:
			points_of_interest.append(point)
	for i in range(0, limitations.size()):
		all_limitations_completed.append(false)
		limitations_start_values.append(limitations[i].value)
		LimitationsIndication.show_indicator(limitations[i],i)
		#LimitationsIndication.set_indicator(limitations[i],i, false)
	
	start_point.set_is_start(true);
	_update_available_to_visit();

func _update_available_to_visit(from_undo: bool = false) -> void:
	for point in available_to_visit:
		point.set_can_next_visit(false);
		if available_to_visit_from.path_indications.has(point):
			var path_effect = available_to_visit_from.path_indications[point];
			if path_effect.target_state != PathEffect.State.TAKEN:
				path_effect.animate_to_state(PathEffect.State.HIDDEN);
				path_effect.skip_animation();
	
	available_to_visit_from = current_visit;
	available_to_visit = current_visit.get_all_can_visit();
	
	print("Av:", available_to_visit.size());
	for point in available_to_visit:
		if not point.is_visited:
			if point.is_start and visited_paths.size() < 3:
				continue;
			
			point.set_can_next_visit(true);
			if available_to_visit_from.path_indications.has(point):
				var path_effect = available_to_visit_from.path_indications[point];
				path_effect.animate_to_state(PathEffect.State.READY);

func _process(delta: float) -> void:
	if GameState.isGameplayRunning():
		if !is_level_finished:
			hover_over()

#handle the input
func _unhandled_input(event: InputEvent) -> void:
	if !is_level_finished:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#region raycast
			var space_state = get_world_3d().direct_space_state
			var mouse_pos = event.position
			var origin = camera.project_ray_origin(mouse_pos)
			var end = origin + camera.project_ray_normal(mouse_pos)*ray_distance
			var query = PhysicsRayQueryParameters3D.create(origin, end)
			query.collide_with_areas = true
			var hit = space_state.intersect_ray(query)
			#endregion
			if hit and hit.collider is PointOfInterest:
				var point: PointOfInterest = hit.collider
				var previous_visit = current_visit
			
				if previous_visit.can_visit_towards(point):
					current_path = [previous_visit, point]
					if !is_path_taken():
						# Footsteps
						if last_path_effect_taken != null:
							last_path_effect_taken.skip_animation();
						if previous_visit.path_indications.has(point):
							var path_effect = previous_visit.path_indications[point];
							path_effect.animate_to_state(PathEffect.State.TAKEN);
							#path_effect.skip_animation();
							last_path_effect_taken = path_effect;
						else:
							last_path_effect_taken = null;
						
						current_visit = point.on_clicked(previous_visit)
						visit_point()
						print("Start" + str(start_point) +" From " + str(previous_visit) + " to " + str(current_visit))
						if current_visit == start_point:
							if are_all_limitations_completed():
								level_complete()
							else:
								BtnIndicators.show_undo(true)
								BtnIndicators.show_reset(true)
						elif !current_visit.is_any_neighbour_available():
							BtnIndicators.show_undo(true)
							BtnIndicators.show_reset(true)
						
						_update_available_to_visit();
				else:
					print("Don't move. Stay at " + str(current_visit))
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			undo_path()
		if event.is_action_pressed("reset path"):
			# DISABLE RESET feature
			#reset_path()
			pass;


#check if path is already taken
func is_path_taken() -> bool:
	for path in visited_paths:
		if path.has(current_path[0]) and path.has(current_path[1]):
			print(str(current_path) + " path taken" + str(path))
			return true
	print("path not taken")
	return false

# Update the limitation status
# Add on is +1 when undo, -1 when choose
func update_status(visit: PointOfInterest, addOn: int)-> void:
	var i : int = 0
	for limitation in limitations:
		if limitation.visit_type == visit.type_point_of_interest:
			# Check if the type is type of duo like zipline,pier
			if duo_visit_types.has(limitation.visit_type):
				var previous = current_path[0]
				print("previous " + str(current_path[0]) + "curr " + str(visit))
				if visit.is_travel_by_vehicle(previous):
					if !visit.get_is_neighbour_by_vehicle_complete(previous):
						if addOn<0:  
							continue #continue to next limitation otherwise limitations is updated
				else:
					continue
				print("not add on")
			print("change limitaiton")
			limitation.value += addOn 
			var value = limitations_start_values[i] - limitation.value 
			print("Limit " + str(limitation.visit_type) + " " + str(limitation.value))
			
			if limitation.numerical_type== Limitations.NumericalType.MIN:
				if limitation.value <= 0:
					all_limitations_completed[i] = true
					LimitationsIndication.set_indicator(limitations[i],i, value, true)
					print("minimun okay")
				else:
					all_limitations_completed[i] = false
					LimitationsIndication.set_indicator(limitations[i],i,value, false)
					print("minimun not okay")
			if limitation.numerical_type == Limitations.NumericalType.MAX:
				if limitation.value >= 0:
					all_limitations_completed[i] = true
					LimitationsIndication.set_indicator(limitations[i],i,value, true)
					print("max okay")
				else:
					all_limitations_completed[i] = false
					LimitationsIndication.set_indicator(limitations[i],i, value, false)
					print("max not okay")
			if limitation.numerical_type ==Limitations.NumericalType.CONSTANT:
				if limitation.value == 0:
					all_limitations_completed[i] = true
					LimitationsIndication.set_indicator(limitations[i],i, value, true)
					print("const okay")
				else:
					all_limitations_completed[i] = false
					LimitationsIndication.set_indicator(limitations[i],i, value, false)
					print("const not okay")
		i+=1


#check if all limitations are completed
func are_all_limitations_completed() -> bool:
	for is_complete in all_limitations_completed:
		if !is_complete:
			return false
	return true

func level_complete() -> void:
	is_level_finished = true
	LimitationsIndication.hide_indicators()
	LevelManager.to_next_level()

func visit_point() -> void:
	update_status(current_visit,-1) #update limitation status
	visited_paths.append(current_path)
	on_going_at.emit(current_visit) #probably you need the current_visit as an input?

#undo path
func undo_path() -> void:
	
	if visited_paths.size()>=1 or current_visit != start_point:
		if last_hover_over:
			last_hover_over.hover_over(false)
		BtnIndicators.show_undo(false)
		BtnIndicators.show_reset(false)
		var last_path = visited_paths.pop_back()
		current_path =  last_path
		
		if last_path:
			last_path[1].undo_point_of_interest(last_path[0])
			update_status(last_path[1], 1)
			current_visit = last_path[0]
			print("current visit = " + str(current_visit))
			reseting_hover_over.emit()
			on_going_at.emit(current_visit)
			
			_update_available_to_visit(true);
		
	
#reset path
func reset_path() -> void:
	
	if last_hover_over:
		last_hover_over.hover_over(false)
	BtnIndicators.show_reset(false)
	BtnIndicators.show_undo(false)
	visited_paths.clear()
	current_visit = start_point
	print("Reset - current visit = " + str(current_visit))
	
	# COMMENTED OUT - NEED TO RESET BOATS AND SUCH
	#for point in points_of_interest:
	#	point.undo_point_of_interest()
		
	var i : int = 0
	for limitation in limitations:
		limitation.value = limitations_start_values[i]
		LimitationsIndication.set_indicator(limitations[i],i, 0, false)
		i=+1
	reseting_hover_over.emit()
	reset.emit(current_visit)
	
	_update_available_to_visit();


func _on_reseting_hover_over() -> void:
	is_reseting = true


#hover over functionality
func hover_over() -> void:
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mouse_pos)
	var end = origin + camera.project_ray_normal(mouse_pos)*ray_distance
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	
	var hit = space_state.intersect_ray(query)
	if hit and hit.collider is PointOfInterest:
		is_hovering_over = true
		
		var point = hit.collider
		start_hovering_over.emit(hit.position, point)
		if point != last_hover_over:
			
			
			if last_hover_over:
				last_hover_over.hover_over(false)
				print("mouse exited " + last_hover_over.name)
			print("mouse enter " + point.name)
			last_hover_over = point
			if current_visit.can_visit_towards(point):
				current_path = [current_visit, point]
				if !is_path_taken():
					point.hover_over(true)
				else:
					point.hover_over(false)
		else:
			if last_hover_over and is_reseting:
				print("is reseting " + str(is_reseting))
				
				if current_visit.can_visit_towards(last_hover_over):
					current_path = [current_visit, last_hover_over]
					if !is_path_taken():
						last_hover_over.hover_over(true)
					else:
						last_hover_over.hover_over(false)
			is_reseting = false
				
	else:
		stop_hovering_over.emit()
		is_hovering_over = false
		if last_hover_over:
			print("mouse exited " + last_hover_over.name)
			last_hover_over.hover_over(false)
			last_hover_over = null
