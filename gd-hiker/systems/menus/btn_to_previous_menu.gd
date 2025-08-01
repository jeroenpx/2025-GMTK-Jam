extends Button

@export var menu_container: MenuContainer;

func _ready() -> void:
	pressed.connect(_button_pressed)

func _button_pressed() -> void:
	menu_container.back_to_previous_menu();
