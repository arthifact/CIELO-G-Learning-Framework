extends CanvasLayer

@export var textures: Array[Texture2D] = []

var busy := false
var _next_texture := 0

@onready var _cover: TextureRect = $Background
@onready var _material: ShaderMaterial = _cover.material


func _ready() -> void:
	_set_progress(0.0)
	_cover.hide()


func change_scene(path: String) -> void:
	if busy:
		return
	busy = true

	if not textures.is_empty():
		_cover.texture = textures[_next_texture]
		_next_texture = (_next_texture + 1) % textures.size()

	_cover.show()
	_cover.mouse_filter = Control.MOUSE_FILTER_STOP
	await _fade(0.0, 1.0)
	await get_tree().create_timer(0.5).timeout

	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	await get_tree().process_frame

	await _fade(1.0, 0.0)
	_cover.hide()
	_cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	busy = false


func _set_progress(value: float) -> void:
	_material.set_shader_parameter("progress", value)


func _fade(from: float, to: float) -> void:
	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(_set_progress, from, to, 0.5)
	await tween.finished
