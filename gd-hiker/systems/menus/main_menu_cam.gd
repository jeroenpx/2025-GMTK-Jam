extends Node3D

@export var angle = 10;

@export var lerp_duration: float = 0.1;

var current_ratio: Vector2 = Vector2(0, 0);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport().get_visible_rect().size;
	
	if mouse_pos.x > screen_size.x:
		mouse_pos.x = screen_size.x;
	if mouse_pos.y > screen_size.y:
		mouse_pos.y = screen_size.y;
	if mouse_pos.x < 0:
		mouse_pos.x = 0;
	if mouse_pos.y < 0:
		mouse_pos.y = 0;
		
	var mouse_ratio = - (mouse_pos - screen_size/2) / screen_size.y;
	
	current_ratio = lerp(current_ratio, mouse_ratio, delta / lerp_duration);
	
	transform = Transform3D.IDENTITY.rotated(Vector3(1,0,0), current_ratio.y * deg_to_rad(angle)).rotated(Vector3(0,1,0), current_ratio.x * deg_to_rad(angle));
