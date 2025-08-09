extends Control
@export var camera_distance_y: float
@export var offset_z: float
@onready var subviewport = $TextureRect/SubViewportContainer/SubViewport
@onready var loop_manager : LoopManager = %LoopManager
@onready var zoomed_cam : Camera3D =  $TextureRect/SubViewportContainer/SubViewport/ZoomedCamera


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loop_manager.start_hovering_over.connect(trigger_viewport)
	loop_manager.stop_hovering_over.connect(untrigger_viewport)
	self.visible = false



func trigger_viewport(visit_point:Vector3):
	
	var visit_pos= visit_point#.position #= loop_manager.current_visit.position
	var dist_z = visit_pos.z - offset_z + camera_distance_y #tan45 = 1
	zoomed_cam.position = Vector3(visit_pos.x, camera_distance_y, dist_z)
	self.position = get_viewport().get_mouse_position()+ Vector2(-subviewport.size.x*0.5, -subviewport.size.y*0.5)
	#self.position = main_cam.unproject_position(visit_pos)+ Vector2(-subviewport.size.x*0.5, -subviewport.size.y*0.5)
	self.visible = true


func untrigger_viewport():
	self.visible = false
