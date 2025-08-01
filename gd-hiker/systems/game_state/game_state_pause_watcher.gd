extends Node

var enterdevcount: int = 0;
var enterdevsince: int = 0;
@export var devmenu_time_ms: int = 2000;
@export var devmenu_count: int = 6;
var devmode_active: bool = false;

func _ready():
	GameState.continueGame();

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if !GameState.isGamePaused():
			GameState.pauseGame();
	
	#if event.is_action_pressed("gamepad_start"):
	#	if !GameState.isGamePaused():
	#		GameState.pauseGame();
	#	else:
	#		GameState.continueGame();
	
	#if event.is_action_pressed("click"):
	#	if GameState.isGamePaused():
	#		get_viewport().set_input_as_handled();
	#		GameState.continueGame();
	
	# Open the Dev Menu
	if event.is_action_pressed("dev_menu"):
		var time = Time.get_ticks_msec();
		if time > enterdevsince + devmenu_time_ms:
			enterdevsince = time;
			enterdevcount = 1;
			if devmode_active:
				GameState.enterDevMenu();
				enterdevsince = 0;
		else:
			enterdevcount+=1;
			if enterdevcount >= devmenu_count:
				devmode_active = true;
				GameState.enterDevMenu();
				enterdevsince = 0;
