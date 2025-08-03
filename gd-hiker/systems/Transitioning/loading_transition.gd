extends CanvasLayer

@onready var fade_rect: ColorRect = $ColorRect
@onready var label: Label = $Label
var loaded : float = 0.0
var progress: Array
func transition_to_scene(scene_path: String) ->void:
	# Step 1: Fade to black
	
	var tween = create_tween().tween_property(fade_rect, "modulate:a", 1.0, 0.5)
	await tween.finished
	label.visible = true
	# Step 2: Start loading the scene asynchronously
	ResourceLoader.load_threaded_request(scene_path)

	while true:
		var status = ResourceLoader.load_threaded_get_status(scene_path, progress)
		if progress[0] > loaded:
			loaded = progress[0]
		label.text = str("Loading... ")
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			break
		
		if status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE or status == ResourceLoader.THREAD_LOAD_FAILED:
			push_error("Failed to load scene: " + scene_path)
			label.text = "Unable to load :("
			return
		
		
		
			
		
		await get_tree().process_frame  # Wait until next frame

	
	var packed_scene: PackedScene = ResourceLoader.load_threaded_get(scene_path)
	
	GameState.enter_cinematic("")
	if packed_scene:
		get_tree().change_scene_to_packed(packed_scene)
	
	label.visible = false
	
	tween = create_tween().tween_property(fade_rect, "modulate:a", 0.0, 0.5)
	await tween.finished
