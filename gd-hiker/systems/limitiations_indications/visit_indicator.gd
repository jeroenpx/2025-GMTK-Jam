class_name VisitIndicator
extends HBoxContainer
@export var type: Limitations.VisitType
@onready var visit_logo: Node = $TextureLogo
@onready var check_mark: Node = $TextureLogo/CheckMark
@onready var label: Label = $Label

func show_indicator(limitation: Limitations)-> void:
	if type == limitation.visit_type:
		self.visible = true

func set_indicator(limitation: Limitations, completed: bool) -> void:
	if type == limitation.visit_type:
		var txt: String = ""
	
		if !completed:
			match limitation.numerical_type:
				Limitations.NumericalType.MIN:
					txt = "min " + str(limitation.value)
				Limitations.NumericalType.MAX:
					txt = "max " +  str(limitation.value)
				Limitations.NumericalType.CONSTANT:
					txt = str(limitation.value)
			check_mark.visible = false
		else:
			check_mark.visible = true
		label.text = txt




func hide_indicator_all()->void:
	label.text = ""
	check_mark.visible = false
	self.visible = false
