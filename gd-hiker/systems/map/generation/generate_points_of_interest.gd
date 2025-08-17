@tool
@icon("res://systems/map/icons/trowel-bricks-solid-full.svg")
class_name PointOfInterestGenerator
extends MapGen

@export var prefab_point_of_interest: PackedScene;
@export var input_height_grid: DataGrid;
@export var where_to_create: Node3D;

# What radius does a point have?
# RISK of too small: paths around the point might not be considered part of the point, so you can bypass it
# RISK of too large: points which are close together might get connected without a path
@export var paths_arrived_at_point_radius: float = 2.5;

# So, avoid those tiles when you don't want it to look like you arrived
# RISK: if the available area is too small, path might not be found
@export var paths_arrived_at_pier_radius: float = 4;

enum SelectShortestPath {
	CLOCKWISE,
	COUNTERCLOCKWISE,
	RANDOM
}

@export var path_generation_choice: SelectShortestPath;
@export var randomness_seed: int = 0;

@export_tool_button("Generate")
var _do_generate = _generate;

@export_group("Generated Data")
@export var _generated_points: Dictionary[String, PointOfInterest];

enum PathType {
	PATH,
	WATER
}

func do_cleanup(map: Map):
	pass

func _generate():
	generate(self.get_parent() as Map)

func _is_path(type: String, look_for: PathType) -> bool:
	if look_for == PathType.PATH:
		return type == "3" or type == "4";
	elif look_for == PathType.WATER:
		return type == "5" or type == "6";
	return false;

func _pick_direction() -> Array:
	var choice = path_generation_choice;
	if choice == SelectShortestPath.CLOCKWISE:
		# left to right takes the top of the river
		return [
			0,#top-right
			1,#right
			2,#bottom-right
			3,#bottom-left
			4,#left
			5,#top-left
		];
	elif choice == SelectShortestPath.COUNTERCLOCKWISE:
		# left to right takes bottom of the river
		return [
			2,#bottom-right
			1,#right
			0,#top-right
			5,#top-left
			4,#left
			3,#bottom-left
		];
	elif choice == SelectShortestPath.RANDOM:
		var arr = range(6);
		arr.shuffle();
		return arr;
	else:
		return range(6);

func _follow_paths(map: Map, origin: Vector2i, start_name: String, output_paths: Dictionary[PointOfInterest, Array], look_for: PathType):
	var results: Array[String] = [];
	
	# Follow the paths!
	var visited: Dictionary[Vector2i, bool];
	var pending: Dictionary[Vector2i, bool];
	var pending_arr: Array[Vector2i] = [];
	
	var from: Dictionary[Vector2i, Vector2i];
	
	var added_connections: Dictionary[String, bool];
	
	pending[origin] = true;
	pending_arr.push_back(origin);
	
	while pending.size() > 0:
		var at = pending_arr[0];
		pending_arr.remove_at(0);
		pending.erase(at);
		visited[at] = true;
		
		var radius = paths_arrived_at_point_radius;
		if look_for == PathType.WATER:
			radius = paths_arrived_at_pier_radius;
		
		var near_point = map.find_point_name(at, radius);
		if near_point == "" or near_point == start_name or not _generated_points.has(near_point) or (look_for == PathType.WATER and !_generated_points[near_point].connects_land_to_water):
			# Ok, continue traversing
			# Find all neighbouring path tiles
			for dir in _pick_direction():
				var neighbour = Hexagons.hex_neighbour(at, dir);
				if not pending.has(neighbour) and not visited.has(neighbour) and _is_path(map.get_at(neighbour, ""), look_for):
					pending_arr.push_back(neighbour);
					pending[neighbour] = true;
					from[neighbour] = at;
		else:
			# Found a connection
			var connection_id = str(start_name, " -> ", near_point);
			
			if not added_connections.has(connection_id):
				added_connections[connection_id] = true;
				print(connection_id);
				results.push_back(near_point);
				
				var path_back: Array = [];
				var previous = at;
				while previous != null:
					path_back.push_front(previous);
					if from.has(previous):
						previous = from[previous];
					else:
						previous = null;
				
				# Try to follow the path 2 hexagons closer to the point still?
				var near_point_location = map.get_named_point_in_map_space(near_point);
				var closest_dist_sq: float = INF;
				var closest_coord: Vector2i;
				for a in range(10):
					for dir in _pick_direction():
						var neighbour = Hexagons.hex_neighbour(at, dir);
						if _is_path(map.get_at(neighbour, ""), look_for):
							# Ok, this is an option... Is it closer to the target?
							var my_location_in_map_space = Hexagons.hex_to_map_space(neighbour);
							var my_dist_sq = near_point_location.distance_squared_to(my_location_in_map_space);
							if my_dist_sq < closest_dist_sq:
								closest_coord = neighbour;
								closest_dist_sq = my_dist_sq;
					if !is_inf(closest_dist_sq):
						at = closest_coord;
						path_back.push_back(closest_coord);
						if closest_dist_sq < 0.7:
							# We can't get closer
							break;
					else:
						# Path ended??
						break;
					
				# Do not include the start point of the path?
				path_back.remove_at(0);
				
				output_paths[_generated_points[near_point]] = path_back;
	
	return results;

# Implement this function in a subclass
func generate(map: Map):
	# set the global seed
	if path_generation_choice == SelectShortestPath.RANDOM:
		seed(randomness_seed);
	
	var remaining = _generated_points.keys().duplicate();
	var safe_to_remove = true;
	
	# STAGE 1: Generating points
	for x in range(map.dim.x):
		for y in range(map.dim.y):
			var at: Vector2i = Vector2i(x, y);
			var hex_type: String = map.get_at(at, "");
			if hex_type == "4":
				# Found point of interest
				var name_of_point = map.find_point_name(at);
				if not name_of_point:
					print("Found a point of interest without an ID, skipping!");
					safe_to_remove = false;
					continue;
				
				if not _generated_points.has(name_of_point):
					# generate the new point of interest
					var new_point: Node3D = prefab_point_of_interest.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE);
					where_to_create.add_child(new_point);
					new_point.owner = get_tree().edited_scene_root;
					new_point.name = name_of_point;
					
					_generated_points[name_of_point] = new_point;
				else:
					# Keep this one
					remaining.remove_at(remaining.find(name_of_point));
				
				# Always update the position
				var triangle_at = Hexagons.hex_to_center_triangle(at);
				var vertex_at = HexagonTriangleVertexSpace.triangle_to_idx(triangle_at);
				
				# Look up the vertex data
				var point_at = input_height_grid.get_thing(vertex_at);
				
				# Set the position
				_generated_points[name_of_point].position = point_at;
				
				# Is this a pier?
				var is_pier = false;
				for dir in range(6):
					var neighbour = Hexagons.hex_neighbour(at, dir);
					if map.get_at(neighbour, "") == "6":
						is_pier = true;
						break;
				
				_generated_points[name_of_point].connects_land_to_water = is_pier;
	
	# STAGE 2: CONNECTING POINTS
	for x in range(map.dim.x):
		for y in range(map.dim.y):
			var at: Vector2i = Vector2i(x, y);
			var hex_type: String = map.get_at(at, "");
			if hex_type == "4":
				# Found point of interest
				var name_of_point = map.find_point_name(at);
				if not name_of_point:
					continue;
				# Get the "point of interest"
				var point = _generated_points[name_of_point] as PointOfInterest;
				
				# Collect the paths to neighbours:
				var paths: Dictionary[PointOfInterest, Array];
				
				# Follow the neighbours
				var neighbour_ids = _follow_paths(map, at, name_of_point, paths, PathType.PATH);
				
				# Follow the neighbours over the water
				var water_paths: Dictionary[PointOfInterest, Array];
				if point.connects_land_to_water:
					_follow_paths(map, at, name_of_point, water_paths, PathType.WATER);
				
				# Add the neighbours
				var data = [];
				for id in neighbour_ids:
					data.push_back(_generated_points[id]);
				point.neighbours = data;
				
				# Set the paths
				point.paths = paths;
				point.paths_on_water = water_paths;
	
	
	if safe_to_remove:
		for key in remaining:
			_generated_points.erase(key);
			var n = _generated_points[key];
			where_to_create.remove_child(n);
			n.free();
