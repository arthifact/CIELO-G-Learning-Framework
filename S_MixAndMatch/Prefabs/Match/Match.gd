extends Area2D

@export var outline_color: Color = Color8(0, 0, 0)
@export var max_outgoing: int = 0    # how many lines this node can start
@export var max_incoming: int = 0    # how many lines this node can receive
@export var options: Array[Area2D] = []   # only these can be connected to
@export var answers: Array[Area2D] = []

@onready var sprite: Sprite2D                 = $CanvasGroup/Sprite2D
@onready var sfx: AudioStreamPlayer2D         = $AudioStreamPlayer2D
@onready var outline_shader: CanvasGroup      = $CanvasGroup

const OUTLINE_SHADER := preload("res://Global/Assets/Shaders/group_outline.gdshader")
var level_manager: Node = null

func _enter_tree() -> void:
	add_to_group("object_match")

func _ready() -> void:
	var mat = ShaderMaterial.new()
	mat.shader = OUTLINE_SHADER
	outline_shader.material = mat

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)

	_update_outline(false)
	_set_outline_color(outline_color)

func set_level_manager(manager: Node) -> void:
	level_manager = manager

func get_max_outgoing() -> int:
	return max_outgoing

func get_max_incoming() -> int:
	return max_incoming

func is_answer_correct(target: Area2D) -> bool:
	return target in answers

func set_selected(active: bool) -> void:
	_update_outline(active)

func _on_mouse_entered() -> void:
	_play_hover_scale_animation()

func _on_mouse_exited() -> void:
	_play_normal_scale_animation()

func _on_input_event(_v, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_play_click_sound()
		_play_click_scale_animation()
		if level_manager:
			level_manager.select_object(self)

# ════════════════════════════════════════════════════════════
# Logic
# ════════════════════════════════════════════════════════════

func _handle_click() -> void:
	_play_click_sound()
	_play_click_scale_animation()
	if level_manager:
		level_manager.select_object(self)

# ════════════════════════════════════════════════════════════
# Visuals
# ════════════════════════════════════════════════════════════

func _update_outline(active: bool) -> void:
	outline_shader.material.set_shader_parameter("line_thickness", 4.0 if active else 1.0)

func _set_outline_color(c: Color) -> void:
	outline_shader.material.set_shader_parameter("line_color", c)

func _play_hover_scale_animation() -> void:
	create_tween().tween_property(sprite, "scale", Vector2(1.025, 1.025), 0.1)

func _play_normal_scale_animation() -> void:
	create_tween().tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)

func _play_click_scale_animation() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", Vector2(1.05, 1.05), 0.08)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.08)

# ════════════════════════════════════════════════════════════
# Sound
# ════════════════════════════════════════════════════════════

func _play_click_sound() -> void:
	if sfx.stream:
		sfx.play()
