class_name MenuContainer
extends Control

@export var menu_initial: Control;
@export var menus: Dictionary[String, Control];

var menu_stack: Array[String];

func _ready() -> void:
	# NOTE: automatically open the credits at the end?
	LevelManager.on_end_game.connect(goto_credits);



func goto_credits()->void:
	if menus.has("credits"):
		goto_menu("credits");

func goto_menu(menu_id: String):
	if menu_stack.size() > 0:
		var menu_hide = menu_stack[menu_stack.size()-1];
		menus[menu_hide].visible = false;
	else:
		menu_initial.visible = false;
	menu_stack.push_back(menu_id);
	menus[menu_id].visible = true;

func back_to_previous_menu():
	if menu_stack.size() > 0:
		var menu_hide = menu_stack.pop_back();
		menus[menu_hide].visible = false;
		if menu_stack.size() > 0:
			var menu_show = menu_stack[menu_stack.size()-1];
			menus[menu_show].visible = true;
		else:
			menu_initial.visible = true;
		get_viewport().set_input_as_handled();
		return;
	
	if GameState.isGamePaused():
		# Future: handle sub-menus and such
		GameState.continueGame();
		get_viewport().set_input_as_handled();

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		back_to_previous_menu();
