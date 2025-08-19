class_name Path3DPrinter

var st;
var uv_coverage: float;

# uv_coverage = whether the quads uv go from [0-1]
# -> can be useful to halve it when using the "index" feature (storing the quad index in the uv)
func begin(uv_coverage: float = 1.0):
	self.uv_coverage = uv_coverage;
	st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES);

# Print a quad at position with given normal and forward
# OPTIONAL: index, shifts the UV map by this amount (useful for shaders)
# OPTIONAL: side_shift, shifts the position to the side
# NOTE: if forward and normal are not perpendicular, forward is changed
# NOTE: assumes normal and forward are normalized
func print_quad(position: Vector3, normal: Vector3, forward: Vector3, side_length: float, index: Vector2i = Vector2i(0,0), side_shift: float = 0.0):
	# Make forward perpendicular
	forward = forward - normal.dot(forward) * normal;
	forward.normalized();
	
	# Calculate side
	var side = forward.cross(normal);
	
	# Add all the vertices
	var vertices = [
		# First triangle
		Vector2(-1, -1), 
		Vector2(1, -1), 
		Vector2(1, 1), 
		# Second triangle
		Vector2(-1, -1),
		Vector2(1, 1),  
		Vector2(-1, 1), 
		];
	
	for v in vertices:
		var pos = position + (v.x * forward + (v.y + side_shift) * side) * side_length / 2.0;
		var uv = (Vector2(0.5, 0.5) + v*0.5) * uv_coverage + Vector2(index.x * 1.0, index.y * 1.0);
		# Push vertex
		st.set_uv(uv);
		st.set_normal(normal);
		st.add_vertex(pos);

func commit() -> ArrayMesh:
	return st.commit();
