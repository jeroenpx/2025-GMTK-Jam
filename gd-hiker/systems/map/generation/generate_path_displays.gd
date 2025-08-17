@tool
@icon("res://systems/map/icons/trowel-bricks-solid-full.svg")
extends MapGen

# In which property of PointOfInterest do we find the paths?
@export var paths_to_generate = "paths";
@export var clear_first: bool = true;

@export var water_level: float = 0.0;

@export var input_height_grid: DataGrid;
@export var smooth_normals_grid: DataGrid;
@export var point_generator: PointOfInterestGenerator;
@export var prefab_path_line: PackedScene;

@export var sample_distance: float = 1.0;

@export var factor_scale: float = 1.2;
@export var factor_shift: float = .8;

@export var up_shift: float = 0.1;


@export_tool_button("Generate")
var _do_generate = _generate;

@export_group("Generated Data")
@export var _generated_paths: Dictionary[String, PathEffect];

func _generate():
	generate(self.get_parent() as Map)

func do_cleanup(map: Map):
	pass

func _make_name(point_from: String, point_to: String):
	return point_from+"_to_"+point_to

func _make_mesh(name_of_path: String):
	var new_path: Node3D = prefab_path_line.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE);
	add_child(new_path);
	new_path.owner = get_tree().edited_scene_root;
	new_path.name = name_of_path;
	
	_generated_paths[name_of_path] = new_path;
	
# Implement this function in a subclass
func generate(map: Map):
	var points = point_generator._generated_points;
	
	var used_paths: Dictionary[String, bool];
		
	for from_point in points.keys():
		var point = points[from_point];
		
		if point:
			var path_meshes: Dictionary[PointOfInterest, MeshInstance3D];
			if not clear_first:
				for key in point.path_indications.keys():
					path_meshes[key] = point.path_indications[key];
			
			var paths: Dictionary[PointOfInterest, Array] = point.get(paths_to_generate);
			for to_point in paths.keys():
				var name_of_path = _make_name(from_point, to_point.name);
				if not _generated_paths.has(name_of_path):
					_make_mesh(name_of_path);
				
				var meshInst = _generated_paths[name_of_path];
				
				meshInst.mesh = generate_mesh_for(map, paths[to_point]);
				meshInst.path_length = paths[to_point].size()
				meshInst.path_from = point;
				meshInst.path_to = to_point;
				meshInst.visible = true;
				
				path_meshes[to_point] = meshInst;
				used_paths[name_of_path] = true;
			
			# Add the path indications to the point
			point.path_indications = path_meshes;
	
	for path_name in _generated_paths.keys():
		if not used_paths.has(path_name):
			_generated_paths[path_name].visible = false;

func print_quad(st: SurfaceTool, i: int, quad_position: Vector3, normal: Vector3, forward: Vector3):
	# Make forward perpendicular
	forward = forward - normal.dot(forward) * normal;
	forward.normalized();
	
	# Calculate side
	var side = forward.cross(normal);
	
	var side_extra = 1.0 if i%2 == 0 else -1.0;
	
	# Add all the vertices
	var vertices = [
		# First triangle
		Vector2(-1, -1), 
		Vector2(1, -1), 
		Vector2(1, 1), 
		# Second triangle
		Vector2(-1, -1),
		Vector2(1, 1),  
		Vector2(-1, 1), 
		];
	
	for v in vertices:
		var pos = quad_position + (v.x * forward + (v.y + side_extra * factor_shift) * side) * factor_scale / 2.0 * Hexagons.SHORT_SIDE_DIAGONAL + Vector3(0, up_shift, 0);
		var uv = Vector2(0.5, 0.5) + v*0.5 + Vector2(i * 1.0, 0);
		# Push vertex
		st.set_uv(uv);
		st.set_normal(normal);
		st.add_vertex(pos);

# Do a cubic curve interpolation sample at float position i
func sample_cubic_interpolated(path_points_real: Array[Vector3], i: float) -> Vector3:
	var begin = floori(i);
	if begin < 0:
		begin = 0;
	if begin >= path_points_real.size():
		begin = path_points_real.size() -1;
	var end = begin + 1;
	var amount = clampf(i - begin, 0.0, 1.0);
	
	var a = begin-1;
	var b = begin;
	var c = begin+1;
	var d = begin+2;
	if a < 0:
		a = 0;
	if c >= path_points_real.size():
		c = path_points_real.size()-1;
	if d >= path_points_real.size():
		d = path_points_real.size()-1;
	
	return path_points_real[b].cubic_interpolate(path_points_real[c], path_points_real[a], path_points_real[d], amount);

# path_points = Array[Vector2i]
func generate_mesh_for(map: Map, path_points: Array) -> ArrayMesh:
	var path_points_real: Array[Vector3] = [];
	var path_normals_real: Array[Vector3] = [];
	
	# Convert to 3D coordinates
	for p in path_points:
		var triangle_at = Hexagons.hex_to_center_triangle(p);
		var vertex_at = HexagonTriangleVertexSpace.triangle_to_idx(triangle_at);
		var point_at = input_height_grid.get_thing(vertex_at);
		var normal_at = smooth_normals_grid.get_thing(vertex_at);
		
		if point_at.y < water_level:
			point_at.y = water_level;
			normal_at = Vector3(0, 1, 0);
		
		path_points_real.push_back(point_at);
		path_normals_real.push_back(normal_at);
	
	
	# Run through the curve and sample cubic interpolated
	var i_fl = 0;
	var path_points_sampled: Array[Vector3] = [];
	var path_normals_sampled: Array[Vector3] = [];
	while i_fl < path_points_real.size():
		var pos = sample_cubic_interpolated(path_points_real, i_fl);
		var norm = sample_cubic_interpolated(path_normals_real, i_fl).normalized();
		
		path_points_sampled.push_back(pos);
		path_normals_sampled.push_back(norm);
		i_fl += sample_distance;
	
	# Calculate the forward of each quad
	var path_forward_sampled: Array[Vector3] = [];
	for i in range(path_points_sampled.size()):
		var prev = path_points_sampled[max(0, i-1)];
		var next = path_points_sampled[min(path_points_sampled.size()-1, i+1)];
		path_forward_sampled.push_back((next-prev).normalized());
	
	# Build the mesh
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES);
	for i in range(path_points_sampled.size()):
		var pos = path_points_sampled[i];
		var norm = path_normals_sampled[i];
		var forw = path_forward_sampled[i];
		
		print_quad(st, i, pos, norm, forw);
	
	# Make the mesh
	return st.commit();
	
