extends Control
@export var nature_ind: Control
@export var civil_ind: Control
@export var rest_ind: Control
@export var zipline_ind: Control
@export var boat_ind: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.on_game_state_changed.connect(_on_state_change)

func _on_state_change() -> void:
	if !GameState.isGameplayRunning():
		hide_indicators()

func show_indicator(limitation: Limitations)->void:
	match limitation.visit_type:
		Limitations.VisitType.NATURE:

			nature_ind.visible = true
		Limitations.VisitType.CIVILISATION:
			civil_ind.visible = true

		Limitations.VisitType.REST:
			rest_ind.visible = true

		Limitations.VisitType.PIER:
			boat_ind.visible = true

		Limitations.VisitType.ZIPLINE:
			zipline_ind.visible = true


func set_indicator(limitation: Limitations, completed: bool) ->void:
	
	var text: String = ""
	
	if !completed:
		match limitation.numerical_type:
			Limitations.NumericalType.MIN:
				text = "min " + str(limitation.value)
			Limitations.NumericalType.MAX:
				text = "max " +  str(limitation.value)
			Limitations.NumericalType.CONSTANT:
				text = str(limitation.value)
	
	match limitation.visit_type:
		Limitations.VisitType.NATURE:
			nature_ind.get_child(1).text = text
			nature_ind.get_child(2).visible = completed
		Limitations.VisitType.CIVILISATION:
			civil_ind.get_child(1).text = text
			civil_ind.get_child(1).visible = completed
		Limitations.VisitType.REST:
			rest_ind.get_child(1).text = text
			rest_ind.get_child(2).visible = completed
		Limitations.VisitType.PIER:
			boat_ind.get_child(1).text = text
			boat_ind.get_child(2).visible = completed
		Limitations.VisitType.ZIPLINE:
			zipline_ind.get_child(1).text = text
			zipline_ind.get_child(2).visible = completed




func hide_indicators() -> void:
	nature_ind.visible = false
	civil_ind.visible = false
	rest_ind.visible = false
	boat_ind.visible = false
	zipline_ind.visible = false
