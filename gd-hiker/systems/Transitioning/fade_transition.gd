extends CanvasLayer
signal transition_to_black_finished
signal transition_from_black_finished
@onready var image:ColorRect = $ColorRect
@onready var anim: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	image.visible = false
	#anim.animation_finished.connect(_on_animation_finished)


func transition_to_black() -> void:
	#image.visible = true
	#anim.play("fade_to_black")
	image.visible = true
	var tween = create_tween().tween_property(image, "modulate:a", 1, 1)
	await tween.finished
	transition_to_black_finished.emit()
	
func transition_from_black() -> void:
	
	var tween = create_tween().tween_property(image, "modulate:a", 0, 1)
	await tween.finished
	
	transition_from_black_finished.emit()
	image.visible = false
	
func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_to_black":
		#transition_finished.emit()
		anim.play("fade_from_black")
	elif anim.name == "fade_from_black":
		image.visible = false
	
