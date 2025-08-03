class_name PointOfInterest
extends Node3D

@export_category("Config")
@export var neighbours: Array[PointOfInterest] #possible neighbours
@export var type_point_of_interest: Limitations.VisitType

# Highlight stuff
@export_category("Visuals")
@export var floor_indication: CircleEffect;

# State
var is_start: bool = false;
var is_visited: bool = false;
var is_hover: bool = false;
var is_canvisitnext: bool = false;

# A) Change visited state
func on_clicked(current_visit: PointOfInterest) -> PointOfInterest:
	is_visited = true
	_update_floor_color();
	return self

func undo_point_of_interest() -> void:
	is_visited = false
	_update_floor_color();


#check if the previous pointofinterest is in neighbours and this pointofinterest wasn't visited
func can_visit_towards(towards: PointOfInterest) -> bool:
	if towards.is_visited:
		return false
	for neighbour in neighbours:
		if towards == neighbour:
			return true 
	return false

func get_all_can_visit() -> Array[PointOfInterest]:
	return neighbours;

func is_any_neighbour_available() -> bool:
	for neighbour in neighbours:
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

# Change the state of the floor circle
func _update_floor_color() -> void:
	if is_canvisitnext:
		if is_hover:
			floor_indication.set_state(CircleEffect.State.VISIT_OPTION_HOVER);
		else:
			floor_indication.set_state(CircleEffect.State.VISIT_OPTION);
	elif is_visited or is_start:
		floor_indication.set_state(CircleEffect.State.VISITED);
	else:
		floor_indication.set_state(CircleEffect.State.AVAILABLE);
