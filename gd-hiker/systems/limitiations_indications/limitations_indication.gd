extends Control
@export var nature_ind: Control
@export var civil_ind: Control
@export var rest_ind: Control
@export var zipline_ind: Control
@export var boat_ind: Control
@export var array_indicators: Array[VisitIndicator]

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	GameState.on_game_state_changed.connect(_on_state_change)

#func _on_state_change() -> void:
#	if !GameState.isGameplayRunning():
#		show_indicators()
#	else:
#		hide_indicators()


func show_indicator(limitation: Limitations) -> void:
	for indicator in array_indicators:
		indicator.show_indicator(limitation)


func hide_indicators()->void:
	for indicator in array_indicators:
		indicator.hide_indicator_all()



func set_indicator(limitation:Limitations, completed:bool) ->void:
	for indicator in array_indicators:
		indicator.set_indicator(limitation, completed)
	pass
