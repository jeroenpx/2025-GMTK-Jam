@tool
@icon("res://systems/map/icons/trowel-bricks-solid-full.svg")
extends MapGen

@export_category("Options")
@export var point_of_interest_skip: float = 3.0;

@export_category("Inputs")
@export var point_generator: PointOfInterestGenerator;
@export var input_height_grid: DataGrid;

@export_category("Outputs")
@export var output_interest_zone: DataGrid;

@export_tool_button("Generate")
var _do_generate = _generate;

func _generate():
	generate(self.get_parent() as Map)

# Implement this function in a subclass
func generate(map: Map):
	generate_interest_zones(map);

func generate_interest_zones(map: Map):
	output_interest_zone.init(input_height_grid.grid_w, input_height_grid.grid_h);
	for x in range(output_interest_zone.grid_w):
		for y in range(output_interest_zone.grid_h):
			output_interest_zone.put_thing(Vector2i(x, y), 0);
	
	var points = point_generator._generated_points;
	
	for name_of_point in points.keys():
		var point = points[name_of_point];
		if point:
			generate_interest_zone(map, point);

func generate_interest_zone(map: Map, point: PointOfInterest):
	# Location
	var center3D = point.position;
	var center2D = Vector2(center3D.x, center3D.z);
	var max_dist_sq = point_of_interest_skip * point_of_interest_skip;
	
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
			if dist_to_hex > max_dist_sq:
				continue;
			
			for tri in Hexagons.triangles_in_hex:
				var triangle = Hexagons.hex_to_center_triangle(hex) + tri;
				
				# Get the vertex coords of this triangle
				var vertices = Hexagons.calculate_triangle_vertices(triangle);
				var tri_vertices = vertices.duplicate();
				
				# Put the interest zone to 0
				for i in range(3):
					var at = HexagonTriangleVertexSpace.point_to_idx(tri_vertices[i]);
					output_interest_zone.put_thing(at, 1);
				
