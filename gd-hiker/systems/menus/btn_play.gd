extends Button

func _ready() -> void:
	pressed.connect(_button_pressed)

func _button_pressed() -> void:
	LevelManager.change_level("res://levels/ETestScene.tscn")
