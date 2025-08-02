extends Button
@export var scene_path : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_button_pressed)

func _button_pressed() -> void:
	#scene_path = "res://levels/" + scene_path
	LevelManager.change_level(scene_path)
