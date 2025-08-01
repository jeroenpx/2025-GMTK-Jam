@icon("res://systems/effects/icons/wand-magic-sparkles-solid.svg")
@tool
class_name Effect
extends Node3D

@export var auto_play: bool = false;

@export_category("Debug")
@export var try: bool:
	set(value):
		if Engine.is_editor_hint():
			play_effect();

func _ready() -> void:
	if auto_play:
		if !Engine.is_editor_hint():
			play_effect();

func play_effect() -> void:
	for c in get_children():
		if c is SoundEffect:
			c.play_effect();
		if c is ParticleEffect:
			if auto_play and c.emitting:
				continue;
			c.play_effect();
		if c is Effect:
			c.play_effect();
