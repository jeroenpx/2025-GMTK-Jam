class_name VisitIndicator
extends HBoxContainer
@export var type: Limitations.VisitType
@onready var visit_logo: TextureRect = $TextureLogo
@onready var check_mark: Node = $TextureLogo2
@onready var label_const: Label = $Label
@onready var label: Label = $Label2

func show_indicator(limitation: Limitations, img:Texture2D)-> void:
	#if type == limitation.visit_type:
	var txt: String = "0"
	type = limitation.visit_type
	visit_logo.texture = img
	match limitation.numerical_type:
		Limitations.NumericalType.MIN:
			txt = "/ min " + str(limitation.value)
		Limitations.NumericalType.MAX:
			txt = "/ max " +  str(limitation.value)
		Limitations.NumericalType.CONSTANT:
			txt = "/ " +str(limitation.value)
	label_const.text = txt
	self.visible = true

func set_indicator(limitation: Limitations, value:int, completed: bool) -> void:
	if type == limitation.visit_type:
		var txt: String = "0"
		txt = str(value)
		if !completed:
			
			check_mark.visible = false
		else:
			check_mark.visible = true
		label.text = txt




func hide_indicator_all()->void:
	label.text = "0"
	check_mark.visible = false
	self.visible = false
