extends Label

func _ready() -> void:
	AppSettings.register_fps_counter_ui(self);

func _process(delta):
	text = str(int(Engine.get_frames_per_second()))
