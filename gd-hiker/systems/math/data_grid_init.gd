class_name DataGridInit

# initialize the Triangle Grid Structure to fit the size of the Map
static func from_map_triangles(data_grid: DataGrid, map: Map) -> void:
	data_grid.init(ceil(map.bounds.size.x / Hexagons.triangle_width), ceil(map.bounds.size.y / Hexagons.triangle_height * 2.0));

# initialize the Hexagon Grid Structure to fit the size of the Map
static func data_grid_init_from_map_hexagons(data_grid: DataGrid, map: Map) -> void:
	data_grid.init(map.dim.x, map.dim.y);
