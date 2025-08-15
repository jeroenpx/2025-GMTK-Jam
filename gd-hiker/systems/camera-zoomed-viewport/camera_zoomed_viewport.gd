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



func trigger_viewport(visit_point:Vector3, visit_spot: PointOfInterest):
	
	#var visit_pos= visit_point # a. uncomment this if want the view to move
	var visit_pos= visit_spot.position # a. comment this if want the view to move
	var dist_z = visit_pos.z - offset_z + camera_distance_y #tan45 = 1
	zoomed_cam.position = Vector3(visit_pos.x, camera_distance_y, dist_z)
	# b. uncomment the next line if want the view to move
	#self.position = get_viewport().get_mouse_position()+ Vector2(-subviewport.size.x*0.5, -subviewport.size.y*0.5) # b. uncomment this if want the view to move
	# b. comment the next line if want the view to move
	self.position = get_viewport().get_camera_3d().unproject_position(visit_pos)+ Vector2(-subviewport.size.x*0.5, -subviewport.size.y*0.5)
	self.visible = true


func untrigger_viewport():
	self.visible = false
