extends Button

@export var menu_container: MenuContainer;
@export var goto_menu_id: String;

func _ready() -> void:
	pressed.connect(_button_pressed)

func _button_pressed() -> void:
	menu_container.goto_menu(goto_menu_id);
