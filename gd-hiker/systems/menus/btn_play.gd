extends Button

func _ready() -> void:
	pressed.connect(_button_pressed)

func _button_pressed() -> void:
	GameState.enter_cinematic("play");
	LevelManager.change_level("res://levels/ETestScene.tscn")
