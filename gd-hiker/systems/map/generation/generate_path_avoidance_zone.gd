@tool
@icon("res://systems/map/icons/trowel-bricks-solid-full.svg")
extends MapGen

@export_category("Options")
@export var iterations: int = 5;

@export_category("Inputs")
@export var input_paths: DataGrid;

@export_category("Outputs")
@export var output_paths: DataGrid;

@export_tool_button("Generate")
var _do_generate = _generate;

func _generate():
	generate(self.get_parent() as Map)

# Implement this function in a subclass
func generate(map: Map):
	generate_path_avoidance_zone(map);

func spread(from: DataGrid, to: DataGrid, factor: float = 0.95):
	for x in range(from.grid_w):
		for y in range(from.grid_h):
			var at = Vector2i(x, y);
			
			var my_value = from.get_thing(at);
			
			for i in range(6):
				var at_n = Hexagons.hex_neighbour(at, i);
				var neighbour_value = from.get_thing(at_n);
				if neighbour_value != null:
					my_value = max(my_value, neighbour_value * factor);
			
			to.put_thing(at, min(my_value, 1.0));

func generate_path_avoidance_zone(map: Map):
	output_paths.init(input_paths.grid_w, input_paths.grid_h);
	var tmp_grid = DataGrid.new();
	tmp_grid.init(input_paths.grid_w, input_paths.grid_h);
	
	if iterations <= 0:
		return;
	
	var tmpA: DataGrid = output_paths;
	var tmpB: DataGrid = tmp_grid;
	if iterations % 2 == 0:
		tmpA = tmp_grid;
		tmpB = output_paths;
		spread(input_paths, tmp_grid);
	else:
		spread(input_paths, output_paths);
	
	for i in range(iterations - 1):
		spread(tmpA, tmpB);
		var tmpC = tmpB;
		tmpB = tmpA;
		tmpA = tmpC;
