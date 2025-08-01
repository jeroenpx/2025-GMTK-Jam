extends Node

@export var navigate_indication: Control;
@export var undo_indication: Control;
@export var reset_indication: Control;
var showing_navigate = false;
var showing_undo = false;
var showing_reset = false;

func _ready() -> void:
	_update_visibilities()
	
	# TODO: enable again
	GameState.on_game_state_changed.connect(_on_state_change);

func _on_state_change() -> void:
	if GameState.isGameplayRunning():
		_update_visibilities();
	else:
		navigate_indication.visible = false;
		undo_indication.visible = false;

func show_navigate(show: bool) -> void:
	showing_navigate = show;
	_update_visibilities();

func show_undo(show: bool) -> void:
	showing_undo = show;
	_update_visibilities();
	
func show_reset(show: bool) -> void:
	showing_reset = show;
	_update_visibilities();

func _update_visibilities() -> void:
	navigate_indication.visible = false;
	undo_indication.visible = false;
	reset_indication.visible = false;
	
	if showing_undo:
		undo_indication.visible = true;
	if showing_navigate:
		navigate_indication.visible = true;
	if showing_reset:
		reset_indication.visible = true;
