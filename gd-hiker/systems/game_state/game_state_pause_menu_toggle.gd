extends Node

@export var pause_menu: Control;
@export var main_menu: Control;
@export var dev_menu: Control;

@export var main_menu_vignette: ColorRect;
var vignette_tween: Tween;

var showing_pause_menu: bool = true;
var showing_main_menu: bool = true;
var showing_dev_menu: bool = true;

func _ready() -> void:
	GameState.on_game_state_changed.connect(_on_game_state_change);
	GameState.on_cinematic_started.connect(_on_game_state_change);
	_on_game_state_change();

func _toggle_menu(showing_menu: bool, should_show_menu: bool, menu_ui: Control) -> bool:
	if showing_menu != should_show_menu:
		showing_menu = should_show_menu;
		if showing_menu:
			menu_ui.process_mode = Node.PROCESS_MODE_ALWAYS;
			menu_ui.visible = true;
		else:
			menu_ui.process_mode = Node.PROCESS_MODE_DISABLED;
			menu_ui.visible = false;
	return showing_menu;

func _on_game_state_change() -> void:
	var should_show_dev_menu = GameState.isInDevMenu();
	var should_show_end_game = GameState.inEndGame();
	var should_show_pause_menu = GameState.isGamePaused() and not should_show_dev_menu and not should_show_end_game;
	var should_show_main_menu = GameState.isInMainMenu();
	
	showing_dev_menu = _toggle_menu(showing_dev_menu, should_show_dev_menu, dev_menu);
	showing_pause_menu = _toggle_menu(showing_pause_menu, should_show_pause_menu, pause_menu);
	showing_main_menu = _toggle_menu(showing_main_menu, should_show_main_menu, main_menu);
	
	if showing_main_menu:
		if vignette_tween:
			vignette_tween.stop();
			vignette_tween = null;
		main_menu_vignette.color = Color(1,1,1,1);
	else:
		if vignette_tween:
			vignette_tween.stop();
			vignette_tween = null;
		vignette_tween = create_tween();
		vignette_tween.tween_property(main_menu_vignette, "color", Color(1,1,1,0), 3.0);
