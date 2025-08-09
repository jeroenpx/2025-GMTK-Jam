@tool
@icon("res://systems/math/icons/triangle-grid.svg")
class_name DataGrid
extends Node

@export var grid_w: int = -1;
@export var grid_h: int = -1;
@export var grid: Array;

# initialize a custom grid structure to track stuff
func init(w: int, h: int) -> void:
	grid_w = w;
	grid_h = h;
	grid = [];
	grid.resize(grid_w * grid_h);
	

func _to_index(at: Vector2i) -> int:
	return at.x + at.y * grid_w;

# Put something on the Grid structure
func put_thing(at: Vector2i, thing: Variant) -> void:
	if not check_in_bounds(at):
		return;
	
	grid[_to_index(at)] = thing;

# Get something from the grid structure
func get_thing(at: Vector2i) -> Variant:
	if not check_in_bounds(at):
		return null;
	
	return grid[_to_index(at)];

# Check whether a point is inside the map boundaries
func check_in_bounds(at: Vector2i) -> bool:
	return (at.x >= 0 and at.x < grid_w) and (at.y >= 0 and at.y < grid_h);
