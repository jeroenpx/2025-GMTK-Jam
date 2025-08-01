class_name VisitIndicator
extends HBoxContainer
@onready var visit_logo: Node = $TextureLogo
@onready var check_mark: Node = $TextureLogo/CheckMark
@onready var label: Label = $Label

func show_indicator()-> void:
	pass

func set_indicator() -> void:
	pass

func hide_indicator_all()->void:
	visit_logo.visible = false
	check_mark.visible = false
	label.visible = false
