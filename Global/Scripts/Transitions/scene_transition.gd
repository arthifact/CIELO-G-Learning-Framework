extends CanvasLayer

@onready var dissolve_rect: TextureRect = $Background

var mat: ShaderMaterial
var is_transitioning: bool = false

# List of transition textures
var transition_textures: Array[Texture2D] = [
	preload("res://Global/Scripts/Transitions/Backgrounds/1.png"),
	preload("res://Global/Scripts/Transitions/Backgrounds/2.png"),
	preload("res://Global/Scripts/Transitions/Backgrounds/3.png"),
	preload("res://Global/Scripts/Transitions/Backgrounds/4.png"),
	preload("res://Global/Scripts/Transitions/Backgrounds/5.png")
]

var current_index: int = 0  # keeps track of which texture is next

func _ready() -> void:
	mat = dissolve_rect.material as ShaderMaterial
	if mat == null:
		push_error("dissolve_rect must have a ShaderMaterial with a 'progress' uniform.")
		return
	dissolve_rect.material = mat.duplicate() as ShaderMaterial
	mat = dissolve_rect.material as ShaderMaterial

	# Block clicks when visible
	dissolve_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	_set_progress(0.0)
	dissolve_rect.visible = false

func change_scene(target: String, type: String = "dissolve") -> void:
	if is_transitioning:
		return
	match type:
		"dissolve":
			await transition_dissolve(target)
		_:
			get_tree().change_scene_to_file(target)

func transition_dissolve(target: String) -> void:
	is_transitioning = true

	# Cycle through textures in order
	dissolve_rect.texture = transition_textures[current_index]
	current_index = (current_index + 1) % transition_textures.size()

	# 1) Cover current scene, block input
	dissolve_rect.visible = true
	dissolve_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	await _tween_progress(0.0, 1.0, 0.5)

	# 1.5) Pause fully covered
	await get_tree().create_timer(0.5).timeout

	# 2) Swap scenes
	get_tree().change_scene_to_file(target)
	await get_tree().process_frame
	await get_tree().process_frame

	# 3) Reveal new scene
	await _tween_progress(1.0, 0.0, 0.5)

	# Allow clicks again
	dissolve_rect.visible = false
	dissolve_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false

# ════════════════════════════════════════════════════════════
# Helpers
# ════════════════════════════════════════════════════════════
func _set_progress(v: float) -> void:
	mat.set_shader_parameter("progress", v)

func _tween_progress(from_v: float, to_v: float, dur: float) -> Tween:
	var tw := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_method(_set_progress, from_v, to_v, dur)
	await tw.finished
	return tw
