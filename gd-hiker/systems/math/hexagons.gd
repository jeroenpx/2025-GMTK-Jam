@tool
class_name Constants

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


### Triangles in the hexagons
# Start from centerCell
const triangle_height = LONG_SIDE_DIAGONAL / 4;
const triangle_width = SHORT_SIDE_DIAGONAL / 4;

# Check if a triangle is pointing to the left
static func is_triangle_pointing_left (pos: Vector2i) -> bool:
	return (pos.x + pos.y) % 2 == 0;

static func triangle_to_map_space(at: Vector2i) -> Vector2:
	return Vector2(at.x * Constants.triangle_width, at.y * Constants.triangle_height/2.0);

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
