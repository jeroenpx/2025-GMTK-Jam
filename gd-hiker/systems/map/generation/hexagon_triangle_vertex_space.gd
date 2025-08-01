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
