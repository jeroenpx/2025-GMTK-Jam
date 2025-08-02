extends Control
@export var loading_label: Label
var progress: Array
var loaded : float = 0.0
var scene_path: String
var is_ready_to_load: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scene_path = LevelManager.scene_path
	GameState.enter_cinematic("loading")
	ready_to_load_scene()

func ready_to_load_scene() -> void:
	ResourceLoader.load_threaded_request(scene_path)
	await TransitionScreen.transition_from_black_finished
	is_ready_to_load = true
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_ready_to_load:

		var status = ResourceLoader.load_threaded_get_status(scene_path, progress)
		if status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE or status == ResourceLoader.THREAD_LOAD_FAILED:
			# Can't load it... :/
			loading_label.text = "Unable to load level :/"
			set_process(false)
			
		if progress[0] > loaded:
			loaded = progress[0]
		
		loading_label.text = str("Loading... ", int(loaded)*100.0, "%")
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var tree = get_tree()
			await get_tree().create_timer(1.0).timeout
			GameState.enter_cinematic("")
			TransitionScreen.transition_to_black()
			await TransitionScreen.transition_to_black_finished
			
			tree.change_scene_to_packed(ResourceLoader.load_threaded_get(scene_path))
			TransitionScreen.transition_from_black()
			await TransitionScreen.transition_from_black_finished
			
		
