@tool
@icon("res://systems/map/icons/trowel-bricks-solid-full.svg")
extends MapGen

@export var output: MeshInstance3D;
@export var use_smooth_normals: bool = true;
@export var smooth_steps: int = 1;

@export_tool_button("Generate")
var _do_generate = _generate;
@export_tool_button("Randomize")
var _do_randomize = _randomize;

@export_category("Path Vertex Color Generation")
@export var path_sample_straight: Texture2D;
var path_sample_straight_img: Image;

@export_category("Vertex Displacement Noise")
@export var vertex_displace_noise: Texture2D;
@export var vertex_displace_noise_scale: float = 1.0;
@export var vertex_displace_noise_amount: Vector3 = Vector3(1.0, 1.0, 1.0);
@export var vertex_displace_noise_shifted: Vector2;
var vertex_displace_noise_img: Image;

var rng = RandomNumberGenerator.new();

# Sample one of the helper images which contain the gradient of the path
func sample(img: Image, pos: Vector2) -> float:
	var pos_adapted = pos * img.get_height();
	var pixel = Vector2i(roundi(pos_adapted.x), roundi(pos_adapted.y));
	if pixel.x >= 0 and pixel.y >=0 and pixel.x < img.get_width() and pixel.y < img.get_height():
		return img.get_pixelv(pixel).r;
	else:
		return 0;

func sample_color_wrap(img: Image, pos: Vector2) -> Color:
	pos = Vector2(fposmod(pos.x, 1.0), fposmod(pos.y, 1.0));
	var pos_adapted = pos * img.get_height();
	var pixel = Vector2i(floori(pos_adapted.x), floori(pos_adapted.y));
	return img.get_pixelv(pixel);

func is_path(tile_type: String) -> bool:
	return tile_type == "3" or tile_type == "4"

# Do the sampling of the vertex considering all the neighbouring hexagons
func do_vertex_path_sampling(map: Map, hex: Vector2i, vertex: Vector2) -> float:
	var amount_path = 0;
	
	# What should we draw at this triangle?
	var tile_type = map.get_at(hex, "");
	
	if !is_path(tile_type):
		return 0;
	
	# Check the neighbours
	for neighbour in range(6):
		# First neightbour = top-right
		var neighbour_type = map.get_at(Hexagons.hex_neighbour(hex, neighbour), "");
		
		# Rotate vertex to sample the image
		var sample_vertex = vertex;
		
		# 1. rotate depending on which neighbour we are sampling
		var degrees = -(30+60*neighbour);
		sample_vertex = sample_vertex.rotated(deg_to_rad(degrees));
		
		# 2. x and y coordinates = same as the image, but shift!
		sample_vertex = sample_vertex;
		sample_vertex += Vector2(0, .25);
		
		# 3. sample the image
		if is_path(neighbour_type):
			var s = sample(path_sample_straight_img, sample_vertex + Vector2(0.5, 0.5));
			amount_path = min(amount_path + s, 1.0);
	
	return amount_path;

func calculate_normal(A: Vector3, B: Vector3, C: Vector3) -> Vector3:
	var dir = (C - A).cross((B - A));
	var norm = dir.normalized();
	return norm;

func _randomize():
	vertex_displace_noise_shifted = Vector2(rng.randf(), rng.randf());
	_generate();

func _generate():
	generate(self.get_parent() as Map)


func _vertex_idx_to_point(at: Vector2i) -> Vector3:
	at = at - Vector2i(2, 6);
	return Vector3(at.x * Hexagons.triangle_width * 2.0 + (at.y % 2) * Hexagons.triangle_width, 0, at.y * Hexagons.triangle_height/2.0);

func _vertex_point_to_idx(at: Vector3) -> Vector2i:
	var x = floori((at.x + Hexagons.triangle_width/4.0) / (Hexagons.triangle_width * 2.0));
	var y = floori((at.z + Hexagons.triangle_width/4.0) / (Hexagons.triangle_height/2.0));
	return Vector2i(x, y) + Vector2i(2, 6);

func smoothen(from: DataGrid, to: DataGrid):
	for x in range(from.grid_w):
		for y in range(from.grid_h):
			var at = Vector2i(x, y);
			
			var my_vertex = from.get_thing(at);
			var my_count = 1;
			
			for i in range(6):
				var at_n = Hexagons.hex_neighbour(at, i);
				var neighbour_vertex = from.get_thing(at_n);
				if neighbour_vertex != null:
					my_count += 1;
					my_vertex += neighbour_vertex;
			
			to.put_thing(at, my_vertex/my_count);

func calculate_smooth_vertex_normals(from: DataGrid, to: DataGrid):
	for x in range(from.grid_w):
		for y in range(from.grid_h):
			var at = Vector2i(x, y);
			
			var my_vertex = from.get_thing(at);
			var my_normal = Vector3(0,0,0);
			var my_count = 0;
			
			for i in range(6):
				var at_n = Hexagons.hex_neighbour(at, i);
				var neighbour_vertex = from.get_thing(at_n);
				var at_n2 = Hexagons.hex_neighbour(at, (i+1)%6);
				var neighbour_vertex2 = from.get_thing(at_n2);
				if neighbour_vertex != null and neighbour_vertex2 != null:
					my_count += 1;
					
					my_normal += calculate_normal(my_vertex, neighbour_vertex, neighbour_vertex2);
			
			to.put_thing(at, my_normal/my_count);
	

# Implement this function in a subclass
func generate(map: Map):
	# Load the images from the GPU
	path_sample_straight_img = path_sample_straight.get_image();
	vertex_displace_noise_img = vertex_displace_noise.get_image();
	
	# Clean up the previous run (TODO)
	
	
	# Collect the vertex data
	var vgrid = DataGrid.new();
	vgrid.init(ceil(map.bounds.size.x / Hexagons.triangle_width)+20, ceil(map.bounds.size.y / Hexagons.triangle_height * 2.0)+20);
	
	# Init the grid
	for x in range(vgrid.grid_w):
		for y in range(vgrid.grid_h):
			var at = Vector2i(x, y);
			var vertex = _vertex_idx_to_point(at);
			var vertex_2D = Vector2(vertex.x, vertex.z);
					
			# Displace this vertex
			var displace_color = sample_color_wrap(vertex_displace_noise_img, vertex_2D * vertex_displace_noise_scale + vertex_displace_noise_shifted);
			var displace_amount = Vector3(displace_color.r, displace_color.g, displace_color.b) - Vector3(0.5, 0, 0.5);
			vertex += displace_amount * vertex_displace_noise_amount;
			
			# Store
			vgrid.put_thing(at, vertex);
	
	# Smoothen
	var vgrid2 = DataGrid.new();
	vgrid2.init(vgrid.grid_w, vgrid.grid_h);
	
	for i in range(smooth_steps):
		smoothen(vgrid, vgrid2);
		var tmp = vgrid2;
		vgrid2 = vgrid;
		vgrid = tmp;
	
	# Smoothen the path some more?
	# (cut in the landscape?)
	
	
	var smooth_normals_grid = DataGrid.new();
	smooth_normals_grid.init(vgrid.grid_w, vgrid.grid_h);
	calculate_smooth_vertex_normals(vgrid, smooth_normals_grid);
	
	# Build the mesh
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Run through all the hexagons
	for hex_x in range(0, map.dim.x):
		for hex_y in range(0, map.dim.y):
			var hex = Vector2i(hex_x, hex_y);
			var hex_center = Hexagons.hex_to_map_space(hex);
			
			for tri in Hexagons.triangles_in_hex:
				var triangle = Hexagons.hex_to_center_triangle(hex) + tri;
				
				# Get the vertex coords of this triangle
				var vertices = Hexagons.calculate_triangle_vertices(triangle);
				var tri_vertices = vertices.duplicate();
				var tri_vertices_2D: Array[Vector2];
				for i in range(3):
					var v = tri_vertices[i];
					tri_vertices_2D.push_back(Vector2(v.x, v.z));
				
				# Displace the vertices
				for i in range(3):
					var at = _vertex_point_to_idx(tri_vertices[i]);
					
					# Push the displacement back in the array
					tri_vertices[i] = vgrid.get_thing(at);
				
				# Calculate the normal
				var normal = calculate_normal(tri_vertices[0], tri_vertices[1], tri_vertices[2]);
				
				# Do stuff with the vertices
				for i in range(3):
					var v = tri_vertices[i];
					var vertex_2D = tri_vertices_2D[i];
					
					# Figure out what this triangle looks like?
					var sample_vertex = (vertex_2D - hex_center) / Hexagons.LONG_SIDE_DIAGONAL;
					var amount_path = do_vertex_path_sampling(map, hex, sample_vertex);
					
					var color = lerp(Color.BLACK, Color.RED, amount_path);
					
					# Get the smooth normal
					var at = _vertex_point_to_idx(vertices[i]);
					var smooth_normal = smooth_normals_grid.get_thing(at);
					
					# Push vertex
					st.set_color(color);
					st.set_uv(vertex_2D);# not used
					st.set_normal(smooth_normal if use_smooth_normals else normal);
					st.add_vertex(v);
	
	# Make the mesh
	var arr_mesh = st.commit();
	output.mesh = arr_mesh;
