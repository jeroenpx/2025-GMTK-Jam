extends Control

@export var array_indicators: Array[VisitIndicator]
@export var array_logo: Array[Texture2D]
var curr_indicator : int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.on_game_state_changed.connect(_on_state_change)

func _on_state_change() -> void:
	if !GameState.isGameplayRunning():
		self.visible= false
	else:
		self.visible = true


func show_indicator(limitation: Limitations, idx: int) -> void:
	var img = get_texture(limitation)
	array_indicators[idx].show_indicator(limitation,img)


func hide_indicators()->void:
	for indicator in array_indicators:
		indicator.hide_indicator_all()
	curr_indicator = 0



func set_indicator(limitation:Limitations, idx:int, value:int, completed:bool) ->void:
	#for indicator in array_indicators:
	array_indicators[idx].set_indicator(limitation, value, completed)

func get_texture(limitation: Limitations)-> Texture2D:
	match limitation.visit_type:
		Limitations.VisitType.NATURE:
			return array_logo[0]
		Limitations.VisitType.CIVILISATION:
			return array_logo[1]
		Limitations.VisitType.PIER:
			return array_logo[2]
		Limitations.VisitType.ZIPLINE:
			return array_logo[3]
		Limitations.VisitType.REST:
			return array_logo[4]
	return array_logo[0]
