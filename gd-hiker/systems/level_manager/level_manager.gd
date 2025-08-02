extends Node
signal on_end_game()
@export var all_levels: Array [String]
var loading_screen = load("res://systems/loading_screen/loading_screen.tscn")
var scene_path : String
var current_scene_id : int = 0
func _ready() -> void:
	scene_path = all_levels[0]
	current_scene_id = 0
	

func to_next_level() -> void:
	if current_scene_id < all_levels.size()-1:
		current_scene_id +=1
		scene_path = all_levels[current_scene_id]
	
		TransitionScreen.transition_to_scene(scene_path)
		
	else:
		GameState.pauseGame()
		on_end_game.emit()
		print("end game")
		
	

func to_previous_level() -> void:
	if current_scene_id > 0:
		current_scene_id -=1
	else:
		current_scene_id = 0
		GameState.enter_cinematic("main_menu")
	scene_path = all_levels[current_scene_id]
	TransitionScreen.transition_to_scene(scene_path)
	

func to_main_menu() -> void:
	current_scene_id =0
	scene_path = all_levels[current_scene_id]
	GameState.enter_cinematic("main_menu")
	TransitionScreen.transition_to_scene(scene_path)
