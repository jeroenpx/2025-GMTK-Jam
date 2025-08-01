class_name PointOfInterest
extends Node3D
#enum Type{DEFAULT, NATURE, ZIPLINE, PIER, CIVILISATION, REST }
@export var identifier: int
@export var neighbours: Array[PointOfInterest] #possible neighbours
@export var type_point_of_interest: Limitations.VisitType
@onready var highlight = $Highlight
@onready var greyedout = $GreyedOut
var reference_point: Vector3 #reference point that hexagon map will read
var is_visited: bool
var default_color = Color(0,0.619,0.627)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_clicked(current_visit: PointOfInterest) -> PointOfInterest:
	print("click " + str(identifier))
	is_visited = true
	print("move to " + str(identifier))
	greyed_out(true)
	return self


#check if the previous pointofinterest is in neighbours and this pointofinterest wasn't visited
func can_visit(pointId: int) -> bool:
	if is_visited:
		return false
	for neighbour in neighbours:
		if pointId == neighbour.identifier:
			return true 
	return false


func is_any_neighbour_available() -> bool:
	for neighbour in neighbours:
		if !neighbour.is_visited:
			return true
	return false



func hover_over(is_hover_over: bool) -> void:
	highlight.visible = is_hover_over
	print("hovering over = " + str(is_hover_over))

func undo_point_of_interest() -> void:
	is_visited = false
	greyed_out(false)

#func stop_hover_over() -> void:
	#var material = mesh_instance.get_active_material(0)
	#if material == null:
	#	material = StandardMaterial3D.new()
	#	mesh_instance.set_surface_override_material(0, material)

# Change color
	#material.albedo_color = default_color  # default
#	highlight.visible = false
#	print("stop hovering over")

func greyed_out(is_greyed_out: bool) -> void:
	greyedout.visible = is_greyed_out
