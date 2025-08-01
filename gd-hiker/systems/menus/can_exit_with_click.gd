extends Control

@export var menu_container: MenuContainer;

@export var credits: Credits;

func _ready() -> void:
	credits.end_reached.connect(_exit_credits);

func _exit_credits() -> void:
	menu_container.back_to_previous_menu();

func _process(delta: float) -> void:
	if visible:
		if Input.is_action_just_pressed("exit_credits_click"):
			menu_container.back_to_previous_menu();
