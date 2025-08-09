class_name PointOfInterest
extends Node3D

@export_category("Config")
@export var neighbours: Array[PointOfInterest]; #possible neighbours
@export var type_point_of_interest: Limitations.VisitType;

@export_category("Config - travel by vehicle")
@export var neighbours_by_vehicle: Array[PointOfInterest];
@export var vehicles_available: int = 0;
@export var vehicles: Array[Vehicle];

# Highlight stuff
@export_category("Visuals")
@export var floor_indication: CircleEffect;
@export var froggy_placement: FroggyPlacement;

# State
var is_start: bool = false;
var is_visited: bool = false;
var is_hover: bool = false;
var is_canvisitnext: bool = false;
var is_neighbour_by_vehicle_complete: Dictionary[PointOfInterest, bool] = {} #Array[bool] = []
func _ready() -> void:
	_update_vehicles();
	_initialize_is_neighbour_by_vehicle_complete()

func add_vehicle(amount: int) -> void:
	vehicles_available += amount;
	_update_vehicles();

func _update_vehicles() -> void:
	for i in range(vehicles.size()):
		vehicles[i].visible = i < vehicles_available;

func _initialize_is_neighbour_by_vehicle_complete() -> void:
	for neigh_vehicle in neighbours_by_vehicle:
		is_neighbour_by_vehicle_complete[neigh_vehicle] = false
		print("neigh-vehicle" + str(is_neighbour_by_vehicle_complete))

func update_is_neighbour_by_vehicle_complete(neigh_vehicle: PointOfInterest, is_complete: bool) -> void:
	is_neighbour_by_vehicle_complete[neigh_vehicle] = is_complete

func get_is_neighbour_by_vehicle_complete(neigh_vehicle: PointOfInterest) -> bool:
	for vehicle_neighbour in neighbours_by_vehicle:
		if vehicle_neighbour == neigh_vehicle:
			return is_neighbour_by_vehicle_complete[neigh_vehicle]
	return false

func is_travel_by_vehicle(towards: PointOfInterest) -> bool:
	for vehicle_neighbour in neighbours_by_vehicle:
		if vehicle_neighbour == towards:
			return true;
	return false;

# A) Change visited state
func on_clicked(current_visit: PointOfInterest) -> PointOfInterest:
	if current_visit.is_travel_by_vehicle(self):
		self.add_vehicle(1);
		current_visit.add_vehicle(-1);
		update_is_neighbour_by_vehicle_complete(current_visit,  true)
		current_visit.update_is_neighbour_by_vehicle_complete(self,  true)
	
	is_visited = true
	_update_floor_color();
	return self

func undo_point_of_interest(from: PointOfInterest) -> void:
	if from.is_travel_by_vehicle(self):
		self.add_vehicle(-1);
		from.add_vehicle(1);
		update_is_neighbour_by_vehicle_complete(from,  false)
		from.update_is_neighbour_by_vehicle_complete(self,  false)
	
	is_visited = false
	_update_floor_color();


#check if the previous pointofinterest is in neighbours and this pointofinterest wasn't visited
func can_visit_towards(towards: PointOfInterest) -> bool:
	if towards.is_visited:
		return false
	for neighbour in get_all_can_visit():
		if towards == neighbour:
			return true 
	return false

func get_all_can_visit() -> Array[PointOfInterest]:
	var results: Array[PointOfInterest] = [];
	for n in neighbours:
		results.push_back(n);
	if vehicles_available > 0:
		for n in neighbours_by_vehicle:
			results.push_back(n);
		
	return results;

func is_any_neighbour_available() -> bool:
	for neighbour in get_all_can_visit():
		if !neighbour.is_visited:
			return true
	return false


# B) Change hover state
func hover_over(is_hover_over: bool) -> void:
	is_hover = is_hover_over;
	_update_floor_color();

# C) Change "next visit" state
func set_can_next_visit(is_next_visit: bool) -> void:
	is_canvisitnext = is_next_visit;
	_update_floor_color();

# D) Start point should always show as "visited" (unless you can visit it next)
func set_is_start(is_start: bool) -> void:
	self.is_start = is_start;
	_update_floor_color();

# Change the state of the floor circle
func _update_floor_color() -> void:
	if not floor_indication:
		print("Point Of Interest without floor???")
		return;
	
	if is_canvisitnext:
		if is_hover:
			floor_indication.set_state(CircleEffect.State.VISIT_OPTION_HOVER);
		else:
			floor_indication.set_state(CircleEffect.State.VISIT_OPTION);
	elif is_visited or is_start:
		floor_indication.set_state(CircleEffect.State.VISITED);
	else:
		floor_indication.set_state(CircleEffect.State.AVAILABLE);
