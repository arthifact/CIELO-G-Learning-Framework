# object_clickable.gd
extends Area2D

@export var is_correct: bool = false
@export var outline_color: Color = Color8(0, 0, 0)

@onready var sprite: Sprite2D = $CanvasGroup/Sprite2D
@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var outline_shader: CanvasGroup = $CanvasGroup

const OUTLINE_SHADER := preload("res://Global/Assets/Shaders/group_outline.gdshader")
var level_manager: Node = null

# ════════════════════════════════════════════════════════════
# Public
# ════════════════════════════════════════════════════════════

func set_level_manager(manager: Node) -> void:
	level_manager = manager

func set_selected(active: bool) -> void:
	_update_outline(active)

# ════════════════════════════════════════════════════════════
# Lifecycle
# ════════════════════════════════════════════════════════════

func _enter_tree() -> void:
	add_to_group("object_clickable")

func _ready() -> void:
	var mat = ShaderMaterial.new()
	mat.shader = OUTLINE_SHADER
	outline_shader.material = mat
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)

	_update_outline(false)
	_set_outline_color(outline_color)

# ════════════════════════════════════════════════════════════
# Signals
# ════════════════════════════════════════════════════════════

func _on_mouse_entered() -> void:
	_play_hover_scale_animation()

func _on_mouse_exited() -> void:
	_play_normal_scale_animation()

func _on_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_click()

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
