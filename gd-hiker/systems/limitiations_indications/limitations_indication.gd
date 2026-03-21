extends Control

@export var array_indicators: Array[VisitIndicator]

var picked_indicators: Array[VisitIndicator]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.on_game_state_changed.connect(_on_state_change)

func _on_state_change() -> void:
	if !GameState.isGameplayRunning():
		self.visible= false
	else:
		self.visible = true


func show_indicator(limitation: Limitations) -> void:
	for idx in range(array_indicators.size()):
		if array_indicators[idx].type == limitation.visit_type:
			array_indicators[idx].show_indicator(limitation);


func hide_indicators()->void:
	for indicator in array_indicators:
		indicator.hide_indicator_all()
	picked_indicators.clear();



func set_indicator(limitation:Limitations, idx:int, value:int, completed:bool) ->void:
	for my_idx in range(array_indicators.size()):
		if array_indicators[my_idx].type == limitation.visit_type:
			#for indicator in array_indicators:
			array_indicators[my_idx].set_indicator(limitation, value, completed)
