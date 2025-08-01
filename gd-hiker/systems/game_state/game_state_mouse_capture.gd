extends Node

func _ready() -> void:
	GameState.on_game_state_changed.connect(_on_game_state_change);
	_on_game_state_change();

func _on_game_state_change() -> void:
	if GameState.isWorldPaused() or GameState.isInMainMenu() or GameState.running_interaction == "gardening_menu":
		# Don't show the mouse by default. (e.g. for gamepad)
		# However, do it when you used escape to enter the pause menu (see ShouldPauseWatcher)
		
		# EDIT: didn't work first try. Re-introducing simple option
		if Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
	else:
		if Input.mouse_mode != Input.MOUSE_MODE_HIDDEN:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN;


#func _unhandled_input(event):
#	if not GameState.isGamePaused():
#		return;
#	
#	if event is InputEventMouseMotion:
#		# User tried to move the mouse in the pause menu, show it!
#		if Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
#			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
