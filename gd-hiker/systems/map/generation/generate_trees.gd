@tool
@icon("res://systems/map/icons/trowel-bricks-solid-full.svg")
extends MapGen

@export var lock_generation = false;

@export_category("Inputs")
@export var input_height_grid: DataGrid;
@export var smooth_normals_grid: DataGrid;

@export var no_plant_zones: Dictionary[String, DataGrid];
@export var no_plant_tresh: float;

@export var seed: int;

@export_tool_button("Generate")
var _do_generate = _generate;

@export_tool_button("Randomize")
var _do_randomize = _randomize;

func _randomize():
	seed += 1;
	_generate();

func _generate():
	generate_impl(self.get_parent() as Map)

func do_cleanup(map: Map):
	pass;

var rng = RandomNumberGenerator.new();

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

func add_one(layer: GenerateTreesAssetLayer, output: Array[Transform3D]):
	# Pick a random vertex in bounds
	# => put the thing on that vertex!
	# But shifted:
	# Pick a random neighbouring vertex + the one clockwise of that (= so forms a triangle)
	# Pick a random value of shift to both other vertices
	var where = random_vertex();
	var neigh = rng.randi_range(0, 5)
	var shiftA = rng.randf()*.5;
	var shiftB = rng.randf()*.5;
	var scalerand = rng.randf_range(layer.min_scale, layer.max_scale);
	var turnrng = rng.randf()*deg_to_rad(layer.max_turn)*2.0-1.0;
	var tiltrng = rng.randf()*deg_to_rad(layer.max_tilt_angle);
	var tiltdir = rng.randf()*PI*2;
	# End of random stuff (do all of it first so things are predictable)
	
	# Check the no-plant zones
	var no_plant_zone_types = layer.no_plant_zones;
	for type in no_plant_zone_types:
		if check_no_plant_zone(type, where, neigh) > no_plant_tresh:
			return;

	# Lookup resulting point and normal
	var point = smooth_lookup(input_height_grid, where, neigh, shiftA, shiftB);
	var normal = smooth_lookup(smooth_normals_grid, where, neigh, shiftA, shiftB).normalized();
	
	# Make the tilt transform
	var tilt = Basis(Quaternion(Vector3(0, 1, 0), tiltdir) * Quaternion(Vector3(1, 0, 0), tiltrng) * Quaternion(Vector3(0, 1, 0), -tiltdir));
	
	# Make the transform
	var transf = Transform3D(tilt * Basis(lerp(Vector3(0,1,0), normal, layer.terrain_tilt).normalized(), turnrng).scaled(Vector3(1,1,1)*scalerand), point);

	output.push_back(transf);

func generate_layer(map: Map, layer: GenerateTreesAssetLayer):
	if layer.lock_generation:
		return;
	
	var area = map.bounds.size.x * map.bounds.size.y;
	var amount = floori(area * layer.density) / layer.multi_meshes.size();
	
	for m in range(layer.multi_meshes.size()):
		var transforms: Array[Transform3D] = [];
		
		for i in range(floori(amount)):
			add_one(layer, transforms);
		
		# Set it in the MultiMesh
		var multimesh: MultiMeshInstance3D = layer.multi_meshes[m];
		var new_multi = MultiMesh.new();
		new_multi.transform_format = MultiMesh.TRANSFORM_3D;
		new_multi.mesh = multimesh.multimesh.mesh;
		new_multi.transform_format = MultiMesh.TRANSFORM_3D;
		new_multi.custom_aabb = AABB(Vector3(0, 0, 0), Vector3(map.bounds.size.x, 10, map.bounds.size.y));
		new_multi.instance_count = transforms.size();
		new_multi.visible_instance_count = transforms.size();
		for i in range(transforms.size()):
			new_multi.set_instance_transform(i, transforms[i]);
		
		multimesh.multimesh = new_multi;

# Implement this function in a subclass
func generate(map: Map):
	if not lock_generation:
		generate_impl(map);

func generate_impl(map: Map):
	rng.seed = seed;
	
	for layer in get_children():
		if layer is GenerateTreesAssetLayer:
			generate_layer(map, layer);
	
	# DENSITY:
	# -> work with circles
