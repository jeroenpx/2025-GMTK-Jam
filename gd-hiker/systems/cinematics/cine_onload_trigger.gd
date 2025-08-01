extends Node

@export var cinematic: String = "main_menu";

@export var skip_cinematic: bool = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.is_debug_build() and skip_cinematic:
		return;
	
	GameState.enter_cinematic(cinematic);
