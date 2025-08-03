@tool
@icon("res://systems/map/icons/map-location-dot-solid.svg")
class_name Map
extends Node3D

@export var source_file: String = "res://levels/maps/map-test.tmx";

@export_tool_button("Update Map")
var _do_update_map = _update_map;

@export_tool_button("Update Map Only")
var _do_update_map_only = _update_map_only;

@export_tool_button("Cleanup")
var _do_cleanup = _run_cleanup;

@export_group("Parsed Data")
@export var _grid_data: Array;
@export var _annotations: Dictionary[String, Vector3];

@export var dim: Vector2i;
@export var bounds: Rect2;


# Get data at a certain position in the map
func get_at(at: Vector2i, def: String) -> String:
	# NOTE: Flip data so X is right and Y is down
	if at.x >= 0 and at.y >= 0 and at.x < dim.x and at.y < dim.y:
		return _grid_data[at.y][at.x];
	return def;

func find_point_name(near_at: Vector2i, range: float = 1):
	var near_at_map_2D = Hexagons.hex_to_map_space(near_at);
	var near_at_map = Vector3(near_at_map_2D.x, 0, near_at_map_2D.y)/Hexagons.LONG_SIDE_DIAGONAL;
	var range_quad = range * range;
	
	for ann in _annotations.keys():
		var loc = _annotations[ann] / Hexagons.LONG_SIDE_DIAGONAL;
		var dist_sq = loc.distance_squared_to(near_at_map);
		if loc.distance_squared_to(near_at_map) < range_quad:
			return ann;
	return "";

func _update_map() -> void:
	_update_map_only();
	_regenerate_scene();
	
func _update_map_only() -> void:
	_parse();
	_calculate_dimensions();
	_calculate_bounds();
# PARSING STUFF
func _parse() -> void:
	_annotations.clear();
	
	var parser = XMLParser.new()
	parser.open(source_file)
	var in_data = false;
	var tile_w: float = 32;
	var tile_h: float = 32;
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			var node_name = parser.get_node_name()
			if node_name == "data":
				in_data = true;
			if node_name == "map":
				tile_w = float(parser.get_named_attribute_value("tilewidth"));
				tile_h = float(parser.get_named_attribute_value("tileheight"));
			if node_name == "object":
				var obj_name = parser.get_named_attribute_value("name");
				var obj_x = float(parser.get_named_attribute_value("x"));
				var obj_y = float(parser.get_named_attribute_value("y"));
				
				# To world position
				# ASSUMES HEXAGONAL MAP!!!!
				var x = obj_x / tile_w * Hexagons.SHORT_SIDE_DIAGONAL;
				var y = obj_y / tile_h * Hexagons.LONG_SIDE_DIAGONAL;
				var pos = Vector3(x, 0, y) - Hexagons.cellCenter;
				_annotations.set(obj_name, pos);
				
		elif parser.get_node_type() == XMLParser.NODE_TEXT:
			if in_data:
				_grid_data = _parse_csv_layer_data(parser.get_node_data());
		elif parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
			in_data = false;

func _calculate_dimensions() -> void:
	# NOTE: Flip data so X is right and Y is down
	dim = Vector2i(_grid_data[0].size(), _grid_data.size());

func _calculate_bounds() -> void:
	# ASSUMES HEXAGONAL MAP!!!!
	bounds = Rect2(global_position.x, global_position.z, Hexagons.W * dim.x + Hexagons.halfW, Hexagons.H * dim.y);

func _parse_csv_layer_data(csv_data: String) -> Array:
	var grid: Array = [];
	var rows = csv_data.split("\r\n");
	for row in rows:
		# Trim and such
		row = row.strip_edges();
		if row.ends_with(","):
			row = row.substr(0, row.length()-1);
		
		if row == "":
			continue;
		
		# Split it now
		var row_details = row.split(",");
		grid.push_back(row_details);
	return grid;

# Call the generators to build the level
func _regenerate_scene() -> void:
	for child in get_children():
		if child is MapGen:
			child.generate(self);


func _run_cleanup() -> void:
	_grid_data = [];
	_annotations.clear();
	
	for child in get_children():
		if child is MapGen:
			child.do_cleanup(self);
