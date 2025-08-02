extends Button

func _ready() -> void:
	pressed.connect(_button_pressed)

func _button_pressed() -> void:
	LevelManager.to_next_level()
