extends Node

func _process(delta: float) -> void:
	# Check if the window is minimized
	var window_mode = DisplayServer.window_get_mode()
	if window_mode == DisplayServer.WINDOW_MODE_MINIMIZED:
		GameState.enterGameMinimized();
	else:
		GameState.exitGameMinimized();
