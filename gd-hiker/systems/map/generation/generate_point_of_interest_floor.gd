@tool
@icon("res://systems/map/icons/trowel-bricks-solid-full.svg")
extends MapGen

@export var max_dist: float = 10;
@export var min_dist: float = 10;

@export var input_height_grid: DataGrid;
@export var smooth_normals_grid: DataGrid;
@export var point_generator: PointOfInterestGenerator;
@export var prefab_point_of_interest_floor: PackedScene;

@export_tool_button("Generate")
var _do_generate = _generate;

@export_group("Generated Data")
@export var _generated_grounds: Dictionary[String, MeshInstance3D];

func _generate():
	generate(self.get_parent() as Map)

func do_cleanup(map: Map):
	pass

func _make_mesh(name_of_point: String):
	var new_ground: Node3D = prefab_point_of_interest_floor.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE);
	add_child(new_ground);
	new_ground.owner = get_tree().edited_scene_root;
	new_ground.name = name_of_point;
	
	_generated_grounds[name_of_point] = new_ground;
	
# Implement this function in a subclass
func generate(map: Map):
	var points = point_generator._generated_points;
	
	for name_of_point in points.keys():
		var point = points[name_of_point];
		if point:
			if not _generated_grounds.has(name_of_point):
				_make_mesh(name_of_point);
			
			var meshInst = _generated_grounds[name_of_point];
			
			meshInst.mesh = generate_mesh_for(map, point);
			
			# Connect the floor to the point
			point.floor_indication = meshInst;


func generate_mesh_for(map: Map, point: PointOfInterest) -> ArrayMesh:
	# Location
	var center3D = point.position;
	var center2D = Vector2(center3D.x, center3D.z);
	var min_dist_sq = sign(min_dist) * min_dist * min_dist;
	var max_dist_sq = max_dist * max_dist;
	
	# Build the mesh
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Run through all the hexagons
	for hex_x in range(0, map.dim.x):
		for hex_y in range(0, map.dim.y):
			var hex = Vector2i(hex_x, hex_y);
			#var hex_center = Hexagons.hex_to_map_space(hex);
			
			# Always update the position
			var triangle_at = Hexagons.hex_to_center_triangle(hex);
			var vertex_at = HexagonTriangleVertexSpace.triangle_to_idx(triangle_at);
			
			# Look up the vertex data
			var point_at = input_height_grid.get_thing(vertex_at);
			var hex_center = Vector2(point_at.x, point_at.z);
			
			var dist_to_hex = hex_center.distance_squared_to(center2D);
			if dist_to_hex > max_dist_sq or dist_to_hex < min_dist_sq:
				continue;
			
			for tri in Hexagons.triangles_in_hex:
				var triangle = Hexagons.hex_to_center_triangle(hex) + tri;
				
				# Get the vertex coords of this triangle
				var vertices = Hexagons.calculate_triangle_vertices(triangle);
				var tri_vertices = vertices.duplicate();
				
				# Get the vertex displacements
				for i in range(3):
					var at = HexagonTriangleVertexSpace.point_to_idx(tri_vertices[i]);
					tri_vertices[i] = input_height_grid.get_thing(at);
				
				# Do stuff with the vertices
				for i in range(3):
					var v = tri_vertices[i];
					var at = HexagonTriangleVertexSpace.point_to_idx(vertices[i]);
					
					var uv3D = (v - center3D) / max_dist;
					var uv = Vector2(uv3D.x, uv3D.z);

					# Get the smooth normal
					var smooth_normal = smooth_normals_grid.get_thing(at);
					
					# Push vertex
					st.set_uv(uv);
					st.set_normal(smooth_normal);
					st.add_vertex(v);
	
	# Make the mesh
	return st.commit();
