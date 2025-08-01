class_name HexagonTriangleVertexSpace

# Make grid based positions for every triangle
# (easier to store stuff in arrays or look them up)

const vertex_grid_shift = Vector2i(2, 6);

static func idx_to_point(at: Vector2i) -> Vector3:
	at = at - vertex_grid_shift;
	return Vector3(at.x * Hexagons.triangle_width * 2.0 + (at.y % 2) * Hexagons.triangle_width, 0, at.y * Hexagons.triangle_height/2.0);

static func point_to_idx(at: Vector3) -> Vector2i:
	var x = floori((at.x + Hexagons.triangle_width/4.0) / (Hexagons.triangle_width * 2.0));
	var y = floori((at.z + Hexagons.triangle_width/4.0) / (Hexagons.triangle_height/2.0));
	return Vector2i(x, y) + vertex_grid_shift;

# which triangle does this vertex belong to?
# NOTE: always picks the left pointing triangle on the right side of the point.
static func idx_to_triangle(at: Vector2i) -> Vector2i:
	var at_shifted = at - HexagonTriangleVertexSpace.vertex_grid_shift;
	var at_triangle = Vector2i(at_shifted.x*2, at_shifted.y);
	return at_triangle;

static func triangle_to_idx(at: Vector2i) -> Vector2i:
	if Hexagons.is_triangle_pointing_left(at):
		return Vector2i(at.x/2, at.y) + HexagonTriangleVertexSpace.vertex_grid_shift;
	else:
		# Not implemented yet
		printerr("LOOKUP NOT IMPLEMENTED");
		return Vector2i(0, 0);
