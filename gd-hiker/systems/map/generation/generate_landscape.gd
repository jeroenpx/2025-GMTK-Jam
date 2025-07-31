@tool
@icon("res://systems/map/icons/trowel-bricks-solid-full.svg")
extends MapGen

@export var output: MeshInstance3D;

@export var path_sample_straight: Texture2D;
var path_sample_straight_img: Image;

# Sample one of the helper images which contain the gradient of the path
func sample(img: Image, pos: Vector2) -> float:
	var pos_adapted = (pos + Vector2(0.5, 0.5)) * img.get_height();
	var pixel = Vector2i(roundi(pos_adapted.x), roundi(pos_adapted.y));
	if pixel.x >= 0 and pixel.y >=0 and pixel.x < img.get_width() and pixel.y < img.get_height():
		return img.get_pixelv(pixel).r;
	else:
		return 0;

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
			var s = sample(path_sample_straight_img, sample_vertex);
			amount_path = min(amount_path + s, 1.0);
	
	return amount_path;

# Implement this function in a subclass
func generate(map: Map):
	# Load the images from the GPU
	path_sample_straight_img = path_sample_straight.get_image();
	
	# Clean up the previous run (TODO)
	
	
	# Collect the vertices
	var vertices = PackedVector3Array()
	var colors = PackedColorArray()
	
	# Run through all the hexagons
	for hex_x in range(0, map.dim.x):
		for hex_y in range(0, map.dim.y):
			var hex = Vector2i(hex_x, hex_y);
			var hex_center = Hexagons.hex_to_map_space(hex);
			
			for tri in Hexagons.triangles_in_hex:
				var triangle = Hexagons.hex_to_center_triangle(hex) + tri;
				
				# Get the vertex coords of this triangle
				var tri_vertices = Hexagons.calculate_triangle_vertices(triangle);
				for v in tri_vertices:
					vertices.push_back(v);
					
					# Figure out what this triangle looks like?
					var sample_vertex = (Vector2(v.x, v.z) - hex_center) / Hexagons.LONG_SIDE_DIAGONAL;
					
					var amount_path = do_vertex_path_sampling(map, hex, sample_vertex);
					
					colors.push_back(lerp(Color.BLACK, Color.RED, amount_path));
	
	# Generate the Data structure for the Mesh
	var surface_array = [];
	surface_array.resize(Mesh.ARRAY_MAX);
	surface_array[Mesh.ARRAY_VERTEX] = vertices;
	surface_array[Mesh.ARRAY_COLOR] = colors;

	# Create the Mesh.
	var arr_mesh: ArrayMesh = ArrayMesh.new();
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array);
	output.mesh = arr_mesh;
