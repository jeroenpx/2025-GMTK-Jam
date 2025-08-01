extends Button

func _ready() -> void:
	pressed.connect(_button_pressed)
	
	_hide_exit_for_web();

func _button_pressed() -> void:
	get_tree().quit();


func _hide_exit_for_web() -> void:
	if OS.has_feature("web"):
		self.hide()
