extends Control
@export var loading_label: Label
@export var label: Label
var progress: Array
var loaded : float = 0.0
var scene_path: String
var loading: bool
var chunk_resource: Resource
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scene_path = LevelManager.scene_path
	GameState.enter_cinematic("cinematic")
	ResourceLoader.load_threaded_request(scene_path)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	if status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE or status == ResourceLoader.THREAD_LOAD_FAILED:
		# Can't load it... :/
		label.text = "Unable to load level :/"
		set_process(false)
			
	if progress[0] > loaded:
		loaded = progress[0]
		
	loading_label.text = str("Loading... ", int(loaded)*100.0, "%")
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		loading = false
		await get_tree().create_timer(4.0).timeout
		GameState.enter_cinematic("play")
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(scene_path))
