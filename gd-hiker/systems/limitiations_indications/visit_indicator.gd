class_name VisitIndicator
extends Container
@export var type: Limitations.VisitType
@export var check_mark: Node;
@export var label_const: Label;
@export var label: Label;

func show_indicator(limitation: Limitations)-> void:
	#if type == limitation.visit_type:
	var txt: String = "0"
	type = limitation.visit_type
	match limitation.numerical_type:
		Limitations.NumericalType.MIN:
			txt = "/ min " + str(limitation.value)
		Limitations.NumericalType.MAX:
			txt = "/ max " +  str(limitation.value)
			check_mark.visible = true;
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
