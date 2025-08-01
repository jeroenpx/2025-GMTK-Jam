@icon("res://systems/cinematics/icons/circle-stop-solid.svg")
extends CineAction

@export var next_cinematic: String;

func play() -> void:
	GameState.enter_cinematic(next_cinematic);
