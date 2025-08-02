@icon("res://systems/cinematics/icons/wifi-solid-full.svg")
extends CineAction

signal act;

func play() -> void:
	act.emit();
