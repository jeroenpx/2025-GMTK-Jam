shader_type canvas_item;
uniform float radius;


void fragment() {
	vec2 center = vec2(0.5,0.5);
	vec2 local_coord = UV - center;
	float dist = length(local_coord);
	float circleRadius = radius/float(2);
	if(dist>circleRadius){
		discard;
		}
	


}


