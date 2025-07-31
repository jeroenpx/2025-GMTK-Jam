class_name PointOfInterest
extends Node3D
enum Type{DEFAULT, NATURE, ZIPLINE, PIER, CIVILISATION, }
@export var identifier: int
@export var neighbours: Array[PointOfInterest] #possible neighbours
@export var type_point_of_interest: Type
var reference_point: Vector3 #reference point that hexagon map will read
var is_visited: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_clicked(current_visit: PointOfInterest) -> PointOfInterest:
	print("click " + str(identifier))
	is_visited = true
	print("move to " + str(identifier))
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

func update_points() -> int:
	match type_point_of_interest:
		Type.NATURE:
			return 100
		Type.ZIPLINE:
			return 200
		Type.PIER:
			return 200
		Type.CIVILISATION:
			return 50
		Type.DEFAULT:
			return 0
	return 0
