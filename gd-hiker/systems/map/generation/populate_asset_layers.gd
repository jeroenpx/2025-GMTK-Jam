@tool
#icon: res://systems/asset_layer/icons/arrows-down-to-line-solid-full.svg
@icon("uid://c8t2kgb3p5ch2")
extends AssetPlacerBase

@export var lock_generation = false;

@export_category("Inputs")
@export var input_height_grid: DataGrid;
@export var smooth_normals_grid: DataGrid;

@export var no_plant_zones: Dictionary[String, DataGrid];
@export var no_plant_tresh: float;

var map: Map;

func _randomize():
	seed += 1;
	_generate();

func _generate():
	map = self.get_parent() as Map;
	_generate_impl()

func generate(map: Map):
	if not lock_generation:
		self.map = map;
		_generate_impl();

#
# Bounds
#
func _calculate_bounds() -> Rect2:
	return map.bounds;

#
# Placement logic
#

func random_vertex() -> Vector2i:
	var x = rng.randi_range(10, input_height_grid.grid_w/2 - 10);
	var y = rng.randi_range(10, input_height_grid.grid_h - 10);
	return Vector2i(x, y);

# Do a lookup on the vertex grid
func smooth_lookup(grid: DataGrid, at: Vector2i, neighbour: int, shift_A: float, shift_B: float) -> Vector3:
	var thing1 = grid.get_thing(at);
	var thing2 = grid.get_thing(Hexagons.hex_neighbour(at, neighbour));
	var thing3 = grid.get_thing(Hexagons.hex_neighbour(at, (neighbour+1) % 6));
	
	var result = thing1;
	result += thing2 * shift_A;
	result += thing3 * shift_B;
	var amount = 1.0;
	amount += shift_A;
	amount += shift_B;
	
	return result / amount;

func check_no_plant_zone(type: String, at: Vector2i, neighbour: int):
	var zone = no_plant_zones[type];
	var thing1 = zone.get_thing(at);
	var thing2 = zone.get_thing(Hexagons.hex_neighbour(at, neighbour));
	var thing3 = zone.get_thing(Hexagons.hex_neighbour(at, (neighbour+1) % 6));
	
	return max(thing1, thing2, thing3);

func _add_one(layer: AssetLayer, output: Array[Transform3D]):
	# Pick a random vertex in bounds
	# => put the thing on that vertex!
	# But shifted:
	# Pick a random neighbouring vertex + the one clockwise of that (= so forms a triangle)
	# Pick a random value of shift to both other vertices
	var where = random_vertex();
	var neigh = rng.randi_range(0, 5)
	var shiftA = rng.randf()*.5;
	var shiftB = rng.randf()*.5;
	var placer = layer.placement(rng);
	# End of random stuff (do all of it first so things are predictable)
	
	# Check the no-plant zones
	var no_plant_zone_types = layer.no_plant_zones;
	for type in no_plant_zone_types:
		if check_no_plant_zone(type, where, neigh) > no_plant_tresh:
			return;

	# Lookup resulting point and normal
	var point = smooth_lookup(input_height_grid, where, neigh, shiftA, shiftB);
	var normal = smooth_lookup(smooth_normals_grid, where, neigh, shiftA, shiftB).normalized();
	
	# Make the transform
	var transf = placer.call(point, normal);
	output.push_back(transf);
