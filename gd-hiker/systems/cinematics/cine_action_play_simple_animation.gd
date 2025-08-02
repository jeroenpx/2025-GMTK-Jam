@icon("res://systems/cinematics/icons/masks-theater-solid.svg")
extends CineAction

@export var anim_player: AnimationPlayer;
@export var animation: String;

func play() -> void:
	anim_player.play(animation);
