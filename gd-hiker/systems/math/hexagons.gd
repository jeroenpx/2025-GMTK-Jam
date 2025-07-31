@tool
class_name Hexagons

# How wide is one grid cell (1m) in reality
# = SHORT_SIDE_DIAGONAL
const W = 1.0;
const SHORT_SIDE_DIAGONAL = W;

# Half width = side of a large triangle as well
const halfW = W/2.0;

# Factor needed for the vertical space
const LONG_SIDE_DIAGONAL = W/(3.0/2.0/sqrt(3));# 0.86602540378443864676372317075294

# What that means for the grid
const H = (LONG_SIDE_DIAGONAL + LONG_SIDE_DIAGONAL/2.0) / 2.0;

# add this value to a returned Vector3 of the grid to get the center
const cellCenter = Vector3(0.5 * W, 0, 1/3.0 * H);
const cellCenterVec2 = Vector2(0.5 * W, 1/3.0 * H);


### Triangles in the hexagons
# Start from centerCell
const triangle_height = LONG_SIDE_DIAGONAL / 4;
const triangle_width = SHORT_SIDE_DIAGONAL / 4;

# Check if a triangle is pointing to the left
static func is_triangle_pointing_left (pos: Vector2i) -> bool:
	return (pos.x + pos.y) % 2 == 0;

static func triangle_to_map_space(at: Vector2i) -> Vector2:
	return Vector2(at.x * triangle_width, at.y * triangle_height/2.0);

static func triangle_to_hex_space(at: Vector2i) -> Vector2i:
	var y_temp = at.y + 2;
	# y_temp 0-4 = same horizontal band
	# 5 = switch
	
	var y = y_temp / 6;
	var x = 0;
	if y_temp % 6 == 5:
		# Special case (edge of the hexagon)
		var x_temp = (at.x + 1) / 2;
		if x_temp % 2 != y % 2:
			y += 1;
		x = x_temp / 2;
	else:
		var x_temp = at.x / 2;
		if x_temp % 2 != y % 2:
			x = (x_temp + 1) / 2;
		else:
			x = x_temp / 2;
	
	return Vector2i(x, y);

# Clockwise, starting top-right
static func hex_neighbour(at: Vector2i, dir: int) -> Vector2i:
	var n: Vector2i = Vector2i(at);
	
	if dir == 0:
		n.x += 1;
		n.y -= 1;
	if dir == 1:
		n.x += 1;
	if dir == 2:
		n.x += 1;
		n.y += 1;
	if dir == 3:
		n.y += 1;
	if dir == 4:
		n.x -= 1;
	if dir == 5:
		n.y -= 1;
	
	if at.y % 2 == 0:
		if dir == 0 or dir == 2 or dir == 3 or dir == 5:
			n.x -= 1;
	return n;

static func hex_to_center_triangle(at: Vector2i) -> Vector2i:
	return Vector2i(at.x * 4 + at.y%2 * 2, at.y * 6);

static func hex_to_map_space(at: Vector2i) -> Vector2:
	return Vector2(W * at.x + halfW * (at.y % 2), H * at.y);

const triangles_in_hex: Array[Vector2i] = [
	Vector2i(-1, -3),
	Vector2i(0, -3),
	Vector2i(-2, -2),
	Vector2i(-1, -2),
	Vector2i(0, -2),
	Vector2i(1, -2),
	Vector2i(-2, -1),
	Vector2i(-1, -1),
	Vector2i(0, -1),
	Vector2i(1, -1),
	Vector2i(-2, 0),
	Vector2i(-1, 0),
	Vector2i(0, 0),
	Vector2i(1, 0),
	Vector2i(-2, 1),
	Vector2i(-1, 1),
	Vector2i(0, 1),
	Vector2i(1, 1),
	Vector2i(-2, 2),
	Vector2i(-1, 2),
	Vector2i(0, 2),
	Vector2i(1, 2),
	Vector2i(-1, 3),
	Vector2i(0, 3),
]

static func calculate_triangle_midpoint(at: Vector2i) -> Vector2:
	var triangle_in_map_space = Hexagons.triangle_to_map_space(at);
	var center = Vector3(triangle_in_map_space.x, 0.0, triangle_in_map_space.y);
	
	if is_triangle_pointing_left(at):
		return center + Vector3(triangle_width/3.0 * 2.0, 0, 0);
	else: 
		return center + Vector3(triangle_width/3.0 * 1.0, 0, 0);

static func calculate_triangle_vertices(at: Vector2i) -> Array[Vector3]:
	var triangle_in_map_space = Hexagons.triangle_to_map_space(at);
	var center = Vector3(triangle_in_map_space.x, 0.0, triangle_in_map_space.y);
	
	var vertices: Array[Vector3] = [];
	
	if is_triangle_pointing_left(at):
		vertices.push_back(center);
		vertices.push_back(center + Vector3(triangle_width, 0, -triangle_height/2.0));
		vertices.push_back(center + Vector3(triangle_width, 0, triangle_height/2.0));
	else:
		vertices.push_back(center + Vector3(0, 0, -triangle_height/2.0));
		vertices.push_back(center + Vector3(triangle_width, 0, 0));
		vertices.push_back(center + Vector3(0, 0, +triangle_height/2.0));
	return vertices;
