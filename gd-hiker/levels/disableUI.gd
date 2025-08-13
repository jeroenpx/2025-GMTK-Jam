extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LimitationsIndication.visible = false
	BtnIndicators.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	LimitationsIndication.visible = false
	BtnIndicators.visible = false
